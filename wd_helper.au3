#Include-once
#include "wd_core.au3"

#Region Copyright
#cs
	* WD_Helper.au3
	*
	* MIT License
	*
	* Copyright (c) 2018 Dan Pollak
	*
	* Permission is hereby granted, free of charge, to any person obtaining a copy
	* of this software and associated documentation files (the "Software"), to deal
	* in the Software without restriction, including without limitation the rights
	* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	* copies of the Software, and to permit persons to whom the Software is
	* furnished to do so, subject to the following conditions:
	*
	* The above copyright notice and this permission notice shall be included in all
	* copies or substantial portions of the Software.
	*
	* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	* SOFTWARE.
#ce
#EndRegion Copyright

#Region Many thanks to:
#cs
	- Jonathan Bennett and the AutoIt Team
	- Thorsten Willert, author of FF.au3, which I've used as a model
	- Michał Lipok for all his feedback / suggestions
#ce
#EndRegion Many thanks to:


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_NewTab
; Description ...: Helper function to create new tab using Javascript
; Syntax ........: _WD_NewTab($sSession[, $lSwitch = True[, $iTimeout = -1]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $lSwitch             - [optional] Switch session context to new tab? Default is True.
;                  $iTimeout            - [optional] Period of time to wait before exiting function
;                  $sURL                - [optional] URL to be loaded in new tab
;                  $sFeatures           - [optional] Comma-separated list of requested features of the new tab
; Return values .: Success      - String representing handle of new tab
;                  Failure      - blank string
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_GeneralError
;                  				- $_WD_ERROR_Timeout
; Author ........: Dan Pollak
; Modified ......: 01/12/2019
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_NewTab($sSession, $lSwitch = Default, $iTimeout = Default, $sURL = Default, $sFeatures = Default)
	Local Const $sFuncName = "_WD_NewTab"
	Local $sTabHandle = '', $sLastTabHandle, $hWaitTimer, $iTabIndex, $aTemp

	If $lSwitch = Default Then $lSwitch = True
	If $iTimeout = Default Then $iTimeout = $_WD_DefaultTimeout
	If $sURL = Default Then $sURL = ''
	If $sFeatures = Default Then $sFeatures = ''

	Local $aHandles = _WD_Window($sSession, 'handles')

	If @error <> $_WD_ERROR_Success Or Not IsArray($aHandles) Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), 0, $sTabHandle)
	EndIf

	Local $iTabCount = UBound($aHandles)

	; Get handle to current last tab
	$sLastTabHandle = $aHandles[$iTabCount - 1]

	; Get handle for current tab
	Local $sCurrentTabHandle = _WD_Window($sSession, 'window')

	If @error = $_WD_ERROR_Success Then
		; Search for current tab handle in array of tab handles. If not found,
		; then make the current tab handle equal to the last tab
		$iTabIndex = _ArraySearch($aHandles, $sCurrentTabHandle)

		If @error Then
			$sCurrentTabHandle = $sLastTabHandle
			$iTabIndex = $iTabCount - 1
		EndIf
	Else
		_WD_Window($sSession, 'Switch', '{"handle":"' & $sLastTabHandle & '"}')
		$sCurrentTabHandle = $sLastTabHandle
		$iTabIndex = $iTabCount - 1
	EndIf

	_WD_ExecuteScript($sSession, "window.open(arguments[0], '', arguments[1])", '"' & $sURL & '","' & $sFeatures & '"')

	If @error <> $_WD_ERROR_Success Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), 0, $sTabHandle)
	EndIf

	$hWaitTimer = TimerInit()

	While 1
 		$aTemp = _WD_Window($sSession, 'handles')

		If UBound($aTemp) > $iTabCount Then
			$sTabHandle = $aTemp[$iTabIndex + 1]
			ExitLoop
		EndIf

		If TimerDiff($hWaitTimer) > $iTimeout Then Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Timeout), 0, $sTabHandle)

		Sleep(10)
	WEnd

	If $lSwitch Then
		_WD_Window($sSession, 'Switch', '{"handle":"' & $sTabHandle & '"}')
	Else
		_WD_Window($sSession, 'Switch', '{"handle":"' & $sCurrentTabHandle & '"}')
	EndIf

	Return SetError($_WD_ERROR_Success, 0, $sTabHandle)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Attach
; Description ...: Helper function to attach to existing browser tab
; Syntax ........: _WD_Attach($sSession, $sString[, $sMode = 'title'])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sString             - String to search for
;                  $sMode               - [optional] One of the following search modes:
;                               | Title (Default)
;                               | URL
;                               | HTML
; Return values .: Success      - String representing handle of matching tab
;                  Failure      - blank string
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_InvalidDataType
;                  				- $_WD_ERROR_NoMatch
;                  				- $_WD_ERROR_GeneralError
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_Attach($sSession, $sString, $sMode = Default)
	Local Const $sFuncName = "_WD_Attach"
	Local $sTabHandle = '', $lFound = False, $sCurrentTab = '', $aHandles

	If $sMode = Default Then $sMode = 'title'

	$aHandles = _WD_Window($sSession, 'handles')

	If @error = $_WD_ERROR_Success Then
		$sMode = StringLower($sMode)
		$sCurrentTab = _WD_Window($sSession, 'window')

		For $sHandle In $aHandles

			_WD_Window($sSession, 'Switch', '{"handle":"' & $sHandle & '"}')

			Switch $sMode
				Case "title", "url"
					If StringInStr(_WD_Action($sSession, $sMode), $sString) > 0 Then
						$lFound = True
						$sTabHandle = $sHandle
						ExitLoop
					EndIf

				Case 'html'
					If StringInStr(_WD_GetSource($sSession), $sString) > 0 Then
						$lFound = True
						$sTabHandle = $sHandle
						ExitLoop
					EndIf

				Case Else
					Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Title|URL|HTML) $sOption=>" & $sMode), 0, $sTabHandle)
			EndSwitch
		Next

		If Not $lFound Then
			; Restore prior active tab
			If $sCurrentTab <> '' Then
				_WD_Window($sSession, 'Switch', '{"handle":"' & $sCurrentTab & '"}')
			EndIf

			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_NoMatch), 0, $sTabHandle)
		EndIf
	Else
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_GeneralError), 0, $sTabHandle)
	EndIf

	Return SetError($_WD_ERROR_Success, 0, $sTabHandle)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_LinkClickByText
; Description ...: Simulate a mouse click on a link with text matching the provided string
; Syntax ........: _WD_LinkClickByText($sSession, $sText[, $lPartial = True])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sText               - Text to find in link
;                  $lPartial            - [optional] Search by partial text? Default is True.
; Return values .: Success      - None
;                  Failure      - Sets @error to non-zero
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_NoMatch
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_LinkClickByText($sSession, $sText, $lPartial = Default)
	Local Const $sFuncName = "_WD_LinkClickByText"

	If $lPartial = Default Then $lPartial = True

	Local $sElement = _WD_FindElement($sSession, ($lPartial) ? $_WD_LOCATOR_ByPartialLinkText : $_WD_LOCATOR_ByLinkText, $sText)

	Local $iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		_WD_ElementAction($sSession, $sElement, 'click')
		$iErr = @error

		If $iErr <> $_WD_ERROR_Success Then
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), $_WD_HTTPRESULT)
		EndIf
	Else
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_NoMatch), $_WD_HTTPRESULT)
	EndIf

	Return SetError($_WD_ERROR_Success)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_WaitElement
; Description ...: Wait for a element to be found  in the current tab before returning
; Syntax ........: _WD_WaitElement($sSession, $sStrategy, $sSelector[, $iDelay = 0[, $iTimeout = -1[, $lVisible = False]]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sStrategy           - Locator strategy. See defined constant $_WD_LOCATOR_* for allowed values
;                  $sSelector           - Value to find
;                  $iDelay              - [optional] Milliseconds to wait before checking status
;                  $iTimeout            - [optional] Period of time to wait before exiting function
;                  $lVisible            - [optional] Check visibility of element?
; Return values .: Success      - 1
;                  Failure      - 0 and sets the @error flag to non-zero
;                  @error       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Timeout
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_WaitElement($sSession, $sStrategy, $sSelector, $iDelay = Default, $iTimeout = Default, $lVisible = Default)
	Local Const $sFuncName = "_WD_WaitElement"
	Local $iErr, $iResult = 0, $sElement, $lIsVisible = True

	If $iDelay = Default Then $iDelay = 0
	If $iTimeout = Default Then $iTimeout = $_WD_DefaultTimeout
	If $lVisible = Default Then $lVisible = False

	Sleep($iDelay)

	Local $hWaitTimer = TimerInit()

	While 1
		$sElement = _WD_FindElement($sSession, $sStrategy, $sSelector)
		$iErr = @error

		If $iErr = $_WD_ERROR_Success Then
			If $lVisible Then
				$lIsVisible = _WD_ElementAction($sSession, $sElement, 'displayed')

				If @error Then
					$lIsVisible = False
				EndIf
			EndIf

			If $lIsVisible = True Then
				$iResult = 1
				ExitLoop
			EndIf

;~ 		ElseIf $iErr <> $_WD_ERROR_NoMatch Then
;~ 			ExitLoop
		EndIf

		If (TimerDiff($hWaitTimer) > $iTimeout) Then
			$iErr = $_WD_ERROR_Timeout
			ExitLoop
		EndIf

		Sleep(1000)
	WEnd

	Return SetError(__WD_Error($sFuncName, $iErr), 0, $iResult)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetMouseElement
; Description ...: Retrieves reference to element below mouse pointer
; Syntax ........: _WD_GetMouseElement($sSession)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
; Return values .: Element ID returned by web driver
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://stackoverflow.com/questions/24538450/get-element-currently-under-mouse-without-using-mouse-events
; Example .......: No
; ===============================================================================================================================
Func _WD_GetMouseElement($sSession)
	Local Const $sFuncName = "_WD_GetMouseElement"
	Local $sResponse, $oJSON, $sElement
	Local $sScript = "return Array.from(document.querySelectorAll(':hover')).pop()"

	$sResponse = _WD_ExecuteScript($sSession, $sScript, '')
	$oJSON = Json_Decode($sResponse)
	$sElement = Json_Get($oJSON, "[value][" & $_WD_ELEMENT_ID & "]")

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sElement & @CRLF)
		ConsoleWrite($sFuncName & ': ' & IsObj($sElement) & @CRLF)
	EndIf

Return SetError($_WD_ERROR_Success, 0, $sElement)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetElementFromPoint
; Description ...:
; Syntax ........: _WD_GetElementFromPoint($sSession, $iX, $iY)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $iX                  - an integer value.
;                  $iY                  - an integer value.
; Return values .: Success      - Element ID returned by web driver
;                  Failure      - blank string
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_GetElementFromPoint($sSession, $iX, $iY)
	Local $sResponse, $sElement, $oJSON
    Local $sScript = "return document.elementFromPoint(arguments[0], arguments[1]);"
	Local $sParams = $iX & ", " & $iY

	$sResponse = _WD_ExecuteScript($sSession, $sScript, $sParams)
	$oJSON = Json_Decode($sResponse)
	$sElement = Json_Get($oJSON, "[value][" & $_WD_ELEMENT_ID & "]")

	Return SetError($_WD_ERROR_Success, 0, $sElement)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_LastHTTPResult
; Description ...: Return the result of the last WinHTTP request
; Syntax ........: _WD_LastHTTPResult()
; Parameters ....: None
; Return values .: Result of last WinHTTP request
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_LastHTTPResult()
	Return $_WD_HTTPRESULT
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetFrameCount
; Description ...: This will return how many frames/iframes are in your current window/frame. It will not traverse to nested frames.
; Syntax ........: _WD_GetFrameCount()
; Parameters ....:
; Return values .: Success      - Numeric count of frames, 0 or positive number
;                  Failure      - blank string
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
; Author ........: Decibel, Danp2
; Modified ......: 2018-04-27
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3schools.com/jsref/prop_win_length.asp
; Example .......: No
; ===============================================================================================================================
Func _WD_GetFrameCount($sSession)
    Local Const $sFuncName = "_WD_GetFrameCount"
    Local $sResponse, $oJSON, $iValue

    $sResponse = _WD_ExecuteScript($sSession, "return window.frames.length")

	If @error <> $_WD_ERROR_Success Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), "")
	EndIf

    $oJSON = Json_Decode($sResponse)
    $iValue = Json_Get($oJSON, "[value]")

    Return SetError($_WD_ERROR_Success, 0, Number($iValue))
EndFunc ;==>_WD_GetFrameCount


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_IsWindowTop
; Description ...: This will return a boolean of the session being at the top level, or in a frame(s).
; Syntax ........: _WD_IsWindowTop()
; Parameters ....:
; Return values .: Success      - Boolean response
;                  Failure      - ""
 ;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
; Author ........: Decibel
; Modified ......: 2018-04-27
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3schools.com/jsref/prop_win_top.asp
; Example .......: No
; ===============================================================================================================================
Func _WD_IsWindowTop($sSession)
	Local Const $sFuncName = "_WD_IsWindowTop"
    Local $sResponse, $oJSON
    Local $blnResult

    $sResponse = _WD_ExecuteScript($sSession, "return window.top == window.self")

	If @error <> $_WD_ERROR_Success Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), "")
	EndIf

    $oJSON = Json_Decode($sResponse)
    $blnResult = Json_Get($oJSON, "[value]")

    Return SetError($_WD_ERROR_Success, 0, $blnResult)
EndFunc ;==>_WD_IsWindowTop

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_FrameEnter
; Description ...: This will enter the specified frame for subsequent WebDriver operations.
; Syntax ........: _WD_FrameEnter($sSession, $sIndexOrID)
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - WD Response error message (E.g. "no such frame")
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
; Author ........: Decibel
; Modified ......: 2018-04-27
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_FrameEnter($sSession, $sIndexOrID)
	Local Const $sFuncName = "_WD_FrameEnter"
    Local $sOption
    Local $sResponse, $oJSON
    Local $sValue

    ;*** Encapsulate the value if it's an integer, assuming that it's supposed to be an Index, not ID attrib value.
    If IsInt($sIndexOrID) = True Then
        $sOption = '{"id":' & $sIndexOrID & '}'
    Else
		$sOption = '{"id":{"' & $_WD_ELEMENT_ID & '":"' & $sIndexOrID & '"}}'
    EndIf

    $sResponse = _WD_Window($sSession, "frame", $sOption)

	If @error <> $_WD_ERROR_Success Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), "")
	EndIf

    $oJSON = Json_Decode($sResponse)
    $sValue = Json_Get($oJSON, "[value]")

    ;*** Evaluate the response
    If $sValue <> Null Then
        $sValue = Json_Get($oJSON, "[value][error]")
    Else
        $sValue = True
    EndIf

    Return SetError($_WD_ERROR_Success, 0, $sValue)

EndFunc ;==>_WD_FrameEnter

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_FrameLeave
; Description ...: This will leave the current frame, to its parent, not necessarily the Top, for subsequent WebDriver operations.
; Syntax ........: _WD_FrameLeave()
; Parameters ....:
; Return values .: Success      True
;                  Failure      - WD Response error message (E.g. "chrome not reachable")
; Author ........: Decibel
; Modified ......: 2018-04-27
; Remarks .......: ChromeDriver and GeckoDriver respond differently for a successful operation
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver/#switch-to-parent-frame
; Example .......: No
; ===============================================================================================================================
Func _WD_FrameLeave($sSession)
	Local Const $sFuncName = "_WD_FrameLeave"
    Local $sOption
    Local $sResponse, $oJSON, $asJSON
    Local $sValue

    $sOption = '{}'

    $sResponse = _WD_Window($sSession, "parent", $sOption)

	If @error <> $_WD_ERROR_Success Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception), "")
	EndIf

    ;Chrome--
    ;   Good: '{"value":null}'
    ;   Bad: '{"value":{"error":"chrome not reachable"....
    ;Firefox--
    ;   Good: '{"value": {}}'
    ;   Bad: '{"value":{"error":"unknown error","message":"Failed to decode response from marionette","stacktrace":""}}'

    $oJSON = Json_Decode($sResponse)
    $sValue = Json_Get($oJSON, "[value]")

    ;*** Is this something besides a Chrome PASS?
    If $sValue <> Null Then
        ;*** Check for a nested JSON object
        If Json_IsObject($sValue) = True Then
            $asJSON = Json_ObjGetKeys($sValue)

            ;*** Is this an empty nested object
            If UBound($asJSON) = 0 Then ;Firefox PASS
                $sValue = True
            Else ;Chrome and Firefox FAIL
                $sValue = $asJSON[0] & ":" & Json_Get($oJSON, "[value][" & $asJSON[0] & "]")
            EndIf
        EndIf
    Else ;Chrome PASS
        $sValue = True
    EndIf

	Return SetError($_WD_ERROR_Success, 0, $sValue)
EndFunc ;==>_WD_FrameLeave

; #FUNCTION# ===========================================================================================================
; Name ..........: _WD_HighlightElement
; Description ...:
; Syntax ........: _WD_HighlightElement($sSession, $sElement[, $iMethod = 1])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sElement            - Element ID from _WDFindElement
;                  $iMethod             - [optional] an integer value. Default is 1.
;                  1=style -> Highlight border dotted red
;                  2=style -> Highlight yellow rounded box
;                  3=style -> Highlight yellow rounded box + border  dotted red
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/192730-webdriver-udf-help-support/?do=findComment&comment=1396643
; Example .......: No
; ===============================================================================================================================
Func _WD_HighlightElement($sSession, $sElement, $iMethod = Default)
    Local Const $aMethod[] = ["border: 2px dotted red", _
            "background: #FFFF66; border-radius: 5px; padding-left: 3px;", _
            "border:2px dotted  red;background: #FFFF66; border-radius: 5px; padding-left: 3px;"]

	If $iMethod = Default Then $iMethod = 1
    If $iMethod < 1 Or $iMethod > 3 Then $iMethod = 1

	Local $sJsonElement = '{"' & $_WD_ELEMENT_ID & '":"' & $sElement & '"}'
    Local $sResponse = _WD_ExecuteScript($sSession, "arguments[0].style='" & $aMethod[$iMethod - 1] & "'; return true;", $sJsonElement)
    Local $oJSON = Json_Decode($sResponse)
    Local $sResult = Json_Get($oJSON, "[value]")
    Return ($sResult = "true" ? SetError(0, 0, $sResult) : SetError(1, 0, False))
EndFunc   ;==>_WD_HighlightElement

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_HighlightElements
; Description ...:
; Syntax ........: _WD_HighlightElements($sSession, $aElements[, $iMethod = 1])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $aElements           - an array of Elements ID from _WDFindElement
;                  $iMethod             - [optional] an integer value. Default is 1.
;                  1=style -> Highlight border dotted red
;                  2=style -> Highlight yellow rounded box
;                  3=style -> Highlight yellow rounded box + border  dotted red
; Return values .: Success      - True
;                  Failure      - False
;                  @Extended Number of Highlighted Elements
; Author ........: Danyfirex
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/192730-webdriver-udf-help-support/?do=findComment&comment=1396643
; Example .......: No
; ===============================================================================================================================
Func _WD_HighlightElements($sSession, $aElements, $iMethod = Default)
    Local $iHighlightedElements = 0

	If $iMethod = Default Then $iMethod = 1

    For $i = 0 To UBound($aElements) - 1
        $iHighlightedElements += (_WD_HighlightElement($sSession, $aElements[$i], $iMethod) = True ? 1 : 0)
    Next
    Return ($iHighlightedElements > 0 ? SetError(0, $iHighlightedElements, True) : SetError(1, 0, False))
EndFunc   ;==>_WD_HighlightElements

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_LoadWait
; Description ...: Wait for a browser page load to complete before returning
; Syntax ........: _WD_LoadWait($sSession[, $iDelay = 0[, $iTimeout = -1[, $sElement = '']]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $iDelay              - [optional] Milliseconds to wait before checking status
;                  $iTimeout            - [optional] Period of time to wait before exiting function
;                  $sElement            - [optional] Element ID to confirm DOM invalidation
; Return values .: Success      - 1
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_LoadWait($sSession, $iDelay = Default, $iTimeout = Default, $sElement = Default)
	Local Const $sFuncName = "_WD_LoadWait"
	Local $iErr, $sResponse, $oJSON, $sReadyState

	If $iDelay = Default Then $iDelay = 0
	If $iTimeout = Default Then $iTimeout = $_WD_DefaultTimeout
	If $sElement = Default Then $sElement = ""

	If $iDelay Then Sleep($iDelay)

	Local $hLoadWaitTimer = TimerInit()

	While True
		If $sElement <> '' Then
			_WD_ElementAction($sSession, $sElement, 'name')

			If $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then $sElement = ''
		Else
			$sResponse = _WD_ExecuteScript($sSession, 'return document.readyState', '')
			$iErr = @error

			If $iErr Then
				ExitLoop
			EndIf

			$oJSON = Json_Decode($sResponse)
			$sReadyState = Json_Get($oJSON, "[value]")

			If $sReadyState = 'complete' Then ExitLoop
		EndIf

		If (TimerDiff($hLoadWaitTimer) > $iTimeout) Then
			$iErr = $_WD_ERROR_Timeout
			ExitLoop
		EndIf

		Sleep(100)
	WEnd

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $iErr, ""), 0, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, 0, 1)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Screenshot
; Description ...:
; Syntax ........: _WD_Screenshot($sSession[, $sElement = ''[, $nOutputType = 1]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sElement            - [optional] Element ID from _WDFindElement
;                  $nOutputType         - [optional] One of the following output types:
;                               | 1 - String (Default)
;                               | 2 - Binary
;                               | 3 - Base64

; Return values .: None
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_Screenshot($sSession, $sElement = Default, $nOutputType = Default)
	Local Const $sFuncName = "_WD_Screenshot"
	Local $sResponse, $sResult, $iErr

	If $sElement = Default Then $sElement = ""
	If $nOutputType = Default Then $nOutputType = 1

	If $sElement = '' Then
		$sResponse = _WD_Window($sSession, 'Screenshot')
		$iErr = @error
	Else
		$sResponse = _WD_ElementAction($sSession, $sElement, 'Screenshot')
		$iErr = @error
	EndIf

	If $iErr = $_WD_ERROR_Success Then
		Switch $nOutputType
			Case 1 ; String
				$sResult = BinaryToString(_Base64Decode($sResponse))

			Case 2 ; Binary
				$sResult = _Base64Decode($sResponse)

			Case 3 ; Base64

		EndSwitch
	Else
		$sResult = ''
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), 0, $sResult)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_jQuerify
; Description ...: Inject jQuery library into current session
; Syntax ........: _WD_jQuerify($sSession[, $sjQueryFile = Default[, $iTimeout = Default]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                : $sjQueryFile         - [optional] Path or URL to jQuery source file
;                  $iTimeout            - [optional] Period of time to wait before exiting function
; Return values .: None
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Timeout
;                  				- $_WD_ERROR_GeneralError
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://sqa.stackexchange.com/questions/2921/webdriver-can-i-inject-a-jquery-script-for-a-page-that-isnt-using-jquery
; Example .......: No
; ===============================================================================================================================
Func _WD_jQuerify($sSession, $sjQueryFile = Default, $iTimeout = Default)
	Local Const $sFuncName = "_WD_jQuerify"

	If $sjQueryFile = Default Then
		$sjQueryFile = ""
	Else
		$sjQueryFile = '"' & StringReplace($sjQueryFile, "\", "/") & '"' ; wrap in double quotes and replace backslashes
	EndIf

	If $iTimeout = Default Then $iTimeout = $_WD_DefaultTimeout

	Local $jQueryLoader = _
	"(function(jqueryUrl, callback) {" & _
	"    if (typeof jqueryUrl != 'string') {" & _
	"        jqueryUrl = 'https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js';" & _
	"    }" & _
	"    if (typeof jQuery == 'undefined') {" & _
	"        var script = document.createElement('script');" & _
	"        var head = document.getElementsByTagName('head')[0];" & _
	"        var done = false;" & _
	"        script.onload = script.onreadystatechange = (function() {" & _
	"            if (!done && (!this.readyState || this.readyState == 'loaded' " & _
	"                    || this.readyState == 'complete')) {" & _
	"                done = true;" & _
	"                script.onload = script.onreadystatechange = null;" & _
	"                head.removeChild(script);" & _
	"                callback();" & _
	"            }" & _
	"        });" & _
	"        script.src = jqueryUrl;" & _
	"        head.appendChild(script);" & _
	"    }" & _
	"    else {" & _
	"        jQuery.noConflict();" & _
	"        callback();" & _
	"    }" & _
	"})(arguments[0], arguments[arguments.length - 1]);"

	_WD_ExecuteScript($sSession, $jQueryLoader, $sjQueryFile, True)

	If @error = $_WD_ERROR_Success Then
		Local $hWaitTimer = TimerInit()

		Do
			If TimerDiff($hWaitTimer) > $iTimeout Then
				SetError($_WD_ERROR_Timeout)
				ExitLoop
			EndIf

			Sleep(250)
			_WD_ExecuteScript($sSession, "jQuery")
		Until @error = $_WD_ERROR_Success
	EndIf

	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $iErr & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr))

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ElementOptionSelect
; Description ...: Find and click on an option from a Select element
; Syntax ........: _WD_ElementOptionSelect($sSession, $sStrategy, $sSelector[, $sStartElement = ""])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sStrategy           - Locator strategy. See defined constant $_WD_LOCATOR_* for allowed values
;                  $sSelector           - Value to find
;                  $sStartElement       - [optional] Element ID of element to use as starting point
; Return values .: None
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_NoMatch
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_ElementOptionSelect($sSession, $sStrategy, $sSelector, $sStartElement = Default)
    Local $sElement = _WD_FindElement($sSession, $sStrategy, $sSelector, $sStartElement)

	If $sStartElement = Default Then $sStartElement = ""

    If @error = $_WD_ERROR_Success Then
        _WD_ElementAction($sSession, $sElement, 'click')
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ConsoleVisible
; Description ...: Control visibility of the webdriver console app
; Syntax ........: _WD_ConsoleVisible([$lVisible = False])
; Parameters ....: $lVisible            - [optional] Set to true to show the console
; Return values .: None
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_ConsoleVisible($lVisible = Default)
	Local $sFile = StringRegExpReplace($_WD_DRIVER, "^.*\\(.*)$", "$1")
	Local $pid, $pid2, $hWnd = 0, $aWinList

	If $lVisible = Default Then $lVisible = False

	$pid = ProcessExists($sFile)

	If $pid Then
		$aWinList=WinList("[CLASS:ConsoleWindowClass]")

		For $i=1 To $aWinList[0][0]
			$pid2 = WinGetProcess($aWinList[$i][1])

			If $pid2 = $pid Then
				$hWnd=$aWinList[$i][1]
				ExitLoop
			EndIf
		Next

		If $hWnd<>0 Then
			WinSetState($hWnd, "", $lVisible ? @SW_SHOW : @SW_HIDE)
		EndIf
	EndIf

EndFunc   ;==>_WD_ConsoleVisible

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetShadowRoot
; Description ...:
; Syntax ........: _WD_GetShadowRoot($sSession, $sStrategy, $sSelector, $sStartElement = "")
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sStrategy           - Locator strategy. See defined constant $_WD_LOCATOR_* for allowed values
;                  $sSelector           - Value to find
;                  $sStartElement       - [optional] a string value. Default is "".
; Return values .: Success      - Element ID returned by web driver
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_NoMatch
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_GetShadowRoot($sSession, $sStrategy, $sSelector, $sStartElement = Default)
	Local Const $sFuncName = "_WD_GetShadowRoot"
	Local $sResponse, $sResult, $sJsonElement, $oJson

	If $sStartElement = Default Then $sStartElement = ""

	Local $sElement = _WD_FindElement($sSession, $sStrategy, $sSelector, $sStartElement)
	Local $iErr = @error


	If $iErr = $_WD_ERROR_Success Then
		$sJsonElement = '{"' & $_WD_ELEMENT_ID & '":"' & $sElement & '"}'
		$sResponse = _WD_ExecuteScript($sSession, "return arguments[0].shadowRoot", $sJsonElement)
		$oJson = Json_Decode($sResponse)
		$sResult  = Json_Get($oJson, "[value][" & $_WD_ELEMENT_ID & "]")
    EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResult & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), $_WD_HTTPRESULT, $sResult)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_SelectFiles
; Description ...: Select files for uploading to a website
; Syntax ........: _WD_SelectFiles($sSession, $sStrategy, $sSelector, $sFilename)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sStrategy           - Locator strategy. See defined constant $_WD_LOCATOR_* for allowed values
;                  $sSelector           - Value to find. Should point to element of type <input type="file">
;                  $sFilename           - Full path of file(s) to upload (use newline character [@LF] to separate files)
;
; Return values .: Number of selected files
;
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_NoMatch
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......: If $sFilename is empty, then prior selection is cleared
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_SelectFiles($sSession, $sStrategy, $sSelector, $sFilename)
	Local Const $sFuncName = "_WD_SelectUploadFile"

	Local $sResponse, $sResult, $sJsonElement, $oJson, $sSavedEscape
	Local $sElement = _WD_FindElement($sSession, $sStrategy, $sSelector)
	Local $iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		If $sFilename <> "" Then
			$sSavedEscape = $_WD_ESCAPE_CHARS
			; Convert file string into proper format
			$sFilename = StringReplace(__WD_EscapeString($sFilename), @LF, "\n")
			; Prevent further string escaping
			$_WD_ESCAPE_CHARS = ""
			$sResponse = _WD_ElementAction($sSession, $sElement, 'value', $sFilename)
			$iErr = @error
			; Restore setting
			$_WD_ESCAPE_CHARS = $sSavedEscape
		Else
			$sResponse = _WD_ElementAction($sSession, $sElement, 'clear')
			$iErr = @error
		EndIf

		If $iErr = $_WD_ERROR_Success Then
			$sJsonElement = '{"' & $_WD_ELEMENT_ID & '":"' & $sElement & '"}'
			$sResponse  = _WD_ExecuteScript($sSession, "return arguments[0].files.length", $sJsonElement)
			$oJson = Json_Decode($sResponse)
			$sResult  = Json_Get($oJson, "[value]")
		Else
			$sResult = "0"
		EndIf
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResult & " file(s) selected" & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), $_WD_HTTPRESULT, $sResult)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_IsLatestRelease
; Description ...: Compares local UDF version to latest release on Github
; Syntax ........: _WD_IsLatestRelease()
; Parameters ....: None
; Return values .: Success      - True if values match, otherwise False
;                  Failure      - Null
;
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidValue
;                  				- $_WD_ERROR_InvalidDataType
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_IsLatestRelease()
	Local Const $sFuncName = "_WD_IsLatestRelease"
	Local Const $sGitURL = "https://github.com/Danp2/WebDriver/releases/latest"

	Local $lResult
	Local $sResult = __WD_Get($sGitURL)
	Local $iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		Local $aLatestWDVersion = StringRegExp($sResult, '<a href="/Danp2/WebDriver/releases/tag/(.*)">', 1)
		Local $sLatestWDVersion = $aLatestWDVersion[0]

		$lResult = ($__WDVERSION == $sLatestWDVersion)
	Else
		$lResult = Null
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $lResult & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), $_WD_HTTPRESULT, $lResult)

EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_UpdateDriver
; Description ...: Replace web driver with newer version, if available
; Syntax ........: _WD_UpdateDriver($sBrowser[, $sInstallDir = Default[, $lFlag64 = Default[, $lForce = Default]]])
; Parameters ....: $sBrowser            - Name of browser
;                  $sInstallDir         - [optional] Install directory. Default is @ScriptDir
;                  $lFlag64             - [optional] Install 64bit version? Default is False
;                  $lForce              - [optional] Force update? Default is False
;
; Return values .: True      - Driver was updated
;                  False     - Driver not updated
;
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_NoMatch
;                  				- $_WD_ERROR_InvalidValue
;                  				- $_WD_ERROR_GeneralError
;
; Author ........: Dan Pollak, CyCho
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Local $lResult = _WD_UpdateDriver('FireFox')
; ===============================================================================================================================
Func _WD_UpdateDriver($sBrowser, $sInstallDir = Default, $lFlag64 = Default, $lForce = Default)
	Local $iErr = $_WD_ERROR_Success, $sEXE, $sDriverEXE, $sPath, $sBrowserVersion, $sCmd, $iPID, $lResult = False
	Local $sOutput, $sDriverVersion, $sVersionShort, $sDriverLatest, $sURLNewDriver
	Local $sReturned, $sTempFile, $hFile, $oShell, $FilesInZip, $sResult

	Local Const $sFuncName = "_WD_UpdateDriver"
	Local Const $cRegKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\'

	If $sInstallDir = Default Then $sInstallDir = @ScriptDir
	If $lFlag64 = Default Then $lFlag64 = False
	If $lForce = Default Then $lForce = False

	; Save current debug level and set to none
	Local $WDDebugSave = $_WD_DEBUG
	$_WD_DEBUG = $_WD_DEBUG_None

	$sBrowser = StringLower($sBrowser)

	Switch $sBrowser
		Case 'chrome'
			$sEXE = "chrome.exe"
			$sDriverEXE = "chromedriver.exe"

		Case 'firefox'
			$sEXE = "firefox.exe"
			$sDriverEXE = "geckodriver.exe"
		Case Else
			$iErr = $_WD_ERROR_InvalidValue
	EndSwitch

	If $iErr = $_WD_ERROR_Success Then
		$sPath = RegRead($cRegKey & $sEXE, "")
		$sBrowserVersion = FileGetVersion($sPath)
		$sVersionShort = StringLeft($sBrowserVersion, StringInStr($sBrowserVersion, ".", 0, -1) - 1)

		; Get version of current webdriver
		$sCmd = $sInstallDir & "\" & $sDriverEXE & " --version"
		$iPID = Run($sCmd, $sInstallDir, @SW_HIDE, $STDOUT_CHILD)

		If $iPID Then
			ProcessWaitClose($iPID)
			$sOutput = StdoutRead($iPID)
			$sDriverVersion = StringRegExp($sOutput, "\s+([^\s]+)", 1)[0]
		Else
			$sDriverVersion = "None"
			$iErr = $_WD_ERROR_NoMatch
		EndIf

		; Determine latest available webdriver version
		; for the designated browser
		Switch $sBrowser
			Case 'chrome'
				$sDriverLatest = __WD_Get('https://chromedriver.storage.googleapis.com/LATEST_RELEASE_' & $sVersionShort)
				$sURLNewDriver = "https://chromedriver.storage.googleapis.com/" & $sDriverLatest & "/chromedriver_win32.zip"

			Case 'firefox'
				$sResult = __WD_Get("https://github.com/mozilla/geckodriver/releases/latest")

				If @error = $_WD_ERROR_Success Then
					$sDriverLatest = StringRegExp($sResult, '<a href="/mozilla/geckodriver/releases/tag/(.*)">', 1)[0]
					If StringLeft($sDriverLatest, 1) = 'v' Then $sDriverLatest = StringMid($sDriverLatest, 2)

					$sURLNewDriver = "https://github.com/mozilla/geckodriver/releases/download/v" & $sDriverLatest & "/geckodriver-v" & $sDriverLatest
					$sURLNewDriver &= ($lFlag64) ? "-win64.zip" : "-win32.zip"
				Else
					$iErr = $_WD_ERROR_GeneralError
				EndIf
		EndSwitch

		If ($iErr = $_WD_ERROR_Success And $sDriverLatest > $sDriverVersion) Or $lForce Then
			$sReturned = __WD_Get($sURLNewDriver)

			$sTempFile = _TempFile($sInstallDir, "webdriver_", ".zip")
			$hFile = FileOpen($sTempFile, 18)
			FileWrite($hFile, $sReturned)
			FileClose($hFile)

			; Close any instances of webdriver and delete from disk
			__WD_CloseDriver($sDriverEXE)
			FileDelete($sInstallDir & "\" & $sDriverEXE)

			; Extract new instance of webdriver
			$oShell = ObjCreate ("Shell.Application")
			$FilesInZip = $oShell.NameSpace($sTempFile).items
			$oShell.NameSpace($sInstallDir).CopyHere($FilesInZip, 20)
			FileDelete($sTempFile)

			$iErr = $_WD_ERROR_Success
			$lResult = True
		EndIf
	EndIf

	; Restore prior setting
	$_WD_DEBUG = $WDDebugSave

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $iErr & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), 0, $lResult)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_DownloadFile
; Description ...: Download file and save to disk
; Syntax ........: _WD_DownloadFile($sURL, $sDest)
; Parameters ....: $sURL                - URL representing file to be downloaded
;                  $sDest               - Full path, including filename, of destination file
; Return values .: True      - Download succeeded
;                  False     - Download failed
;
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidValue
;                  				- $_WD_ERROR_GeneralError
;                  				- $_WD_ERROR_NotFound
;
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_DownloadFile($sURL, $sDest)
	Local Const $sFuncName = "_WD_DownloadFile"
	Local $lResult = False

	; Save current debug level and set to none
	Local $WDDebugSave = $_WD_DEBUG
	$_WD_DEBUG = $_WD_DEBUG_None

	Local $sData = __WD_Get($sURL)
	Local $iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		If  $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
			$iErr = $_WD_ERROR_NotFound
		Else
			Local $hFile = FileOpen($sDest, 18)

			If $hFile <> -1 Then
				FileWrite($hFile, $sData)
				FileClose($hFile)

				$lResult = True
			Else
				$iErr = $_WD_ERROR_GeneralError
			EndIf
		EndIf
	EndIf

	; Restore prior setting
	$_WD_DEBUG = $WDDebugSave

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $iErr & @CRLF)
	EndIf

	Return SetError(__WD_Error($sFuncName, $iErr), 0, $lResult)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _Base64Decode
; Description ...:
; Syntax ........: _Base64Decode($input_string)
; Parameters ....: $input_string        - string to be decoded
; Return values .: Decoded string
; Author ........: trancexx
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/81332-_base64encode-_base64decode/
; Example .......: No
; ===============================================================================================================================
Func _Base64Decode($input_string)

    Local $struct = DllStructCreate("int")

    Local $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
            "str", $input_string, _
            "int", 0, _
            "int", 1, _
            "ptr", 0, _
            "ptr", DllStructGetPtr($struct, 1), _
            "ptr", 0, _
            "ptr", 0)

    If @error Or Not $a_Call[0] Then
        Return SetError(1, 0, "") ; error calculating the length of the buffer needed
    EndIf

    Local $a = DllStructCreate("byte[" & DllStructGetData($struct, 1) & "]")

    $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
            "str", $input_string, _
            "int", 0, _
            "int", 1, _
            "ptr", DllStructGetPtr($a), _
            "ptr", DllStructGetPtr($struct, 1), _
            "ptr", 0, _
            "ptr", 0)

    If @error Or Not $a_Call[0] Then
        Return SetError(2, 0, ""); error decoding
    EndIf

    Return DllStructGetData($a, 1)

EndFunc   ;==>_Base64Decode
