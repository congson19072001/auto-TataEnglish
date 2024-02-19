#include-once
#include <array.au3>
#include <File.au3>			; Needed for _WD_UpdateDriver
#include <WinAPIProc.au3>
#include <JSON.au3> ; https://www.autoitscript.com/forum/topic/148114-a-non-strict-json-udf-jsmn
#include <WinHttp.au3> ; https://www.autoitscript.com/forum/topic/84133-winhttp-functions/

#Region Description
; ==============================================================================
; UDF ...........: WD_Core.au3
; Description ...: A UDF for Web Driver automation
; Requirement ...: JSON UDF
;                  https://www.autoitscript.com/forum/topic/148114-a-non-strict-json-udf-jsmn
;                  WinHTTP UDF
;                  https://www.autoitscript.com/forum/topic/84133-winhttp-functions/
;
;                  WebDriver for desired browser
;                  Chrome WebDriver https://sites.google.com/a/chromium.org/chromedriver/downloads
;                  FireFox WebDriver https://github.com/mozilla/geckodriver/releases
;                  Edge WebDriver https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
;
;                  Discussion Thread on Autoit Forums
;                  https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version
;
; Author(s) .....: Dan Pollak
; AutoIt Version : v3.3.14.5
; ==============================================================================
#cs
	v0.2.0.6
	- Changed: _WD_ElementAction handling of return status codes
	- Changed: File separator is now @LF in _WD_SelectFiles
	- Changed: wd_demo
		- Added: DemoUpload
	- Chore: Update description of parameters in _WD_ConsoleVisible
	- Fixed: Proper string escaping in _WD_SelectFiles

	v0.2.0.5
	- Fixed: __WD_CloseDriver regression
	- Fixed: __WD_Get, __WD_Put & __WD_Delete pass additional URL components

	v0.2.0.4
	- Added: _WD_DownloadFile
	- Added: Global variable to hold session details
	- Changed: wd_demo
		- Added: GUI front-end
		- Added: DemoDownload
		- Changed: DemoWindows, DemoTimeouts, DemoElements
	- Fixed: __WD_CloseDriver now closes child console processes

	v0.2.0.3
	- Fixed: Missing include file
	- Fixed: _WD_Execute timeout detection / handling

	v0.2.0.2
	- Added: _WD_IsLatestRelease
	- Added: _WD_UpdateDriver
	- Changed: __WD_Get and __WD_Put updated to detect invalid URL
	- Changed: __WD_Get and __WD_Put updated to handle both HTTP and HTTPS requests
	- Changed: __WD_CloseDriver - Optional parameter to indicate driver to close
	- Fixed: __WD_Put and __WD_Delete use correct port
	- Fixed: _WD_Navigate timeout detection / handling

	v0.2.0.1
	- Added: _WD_GetShadowRoot
	- Added: _WD_SelectFiles
	- Fixed: Additional error checking in _WD_WaitElement
	- Fixed: Standardize coding of frame related functions
	- Changed: Added backslash to list of characters to escape
	- Changed: Modified _WD_jQuerify with additional parameters for timeout / alternate jQuery source

   v0.1.0.21
   - Fixed: 'maximize', 'minimize', 'fullscreen' options now work correctly in _WD_Window
   - Fixed: Prevent runtime error dialog from appearing when function call succeeded

	V0.1.0.20
	- Fixed: Escape string passed to _WD_ElementAction when setting element's value
   - Fixed: Return value from _WD_Window should be "" on error
   - Fixed: Current tab handling in _WD_Attach

	V0.1.0.19
	- Added: _WD_ConsoleVisible
	- Added: __WD_EscapeString
	- Changed: Escape double quotes in string passed to _WD_FindElement, _WD_ExecuteScript
	- Changed: _WD_Window with 'rect' command now returns Dictionary object instead of raw JSON string

	V0.1.0.18
	- Changed: Add optional parameters to _WD_NewTab for URL and Features
	- Added: _WD_jQuerify
	- Added: _WD_ElementOptionSelect

	V0.1.0.17
	- Changed: Add 'Screenshot' option to _WD_ElementAction
	- Changed: Extract JSON value when taking screenshot in _WD_Window
	- Changed: Rework coding of _WD_ElementAction
	- Fixed: Error handling in __WD_Get
	- Fixed: _WD_NewTab failed in some situations
    - Fixed: _WD_Window error handling
	- Added: _WD_Screenshot

	V0.1.0.16
	- Changed: Add async support to _WD_ExecuteScript
	- Changed: Add debug info to _WD_GetMouseElement
	- Fixed: Set element value in _WD_ElementAction
	- Fixed: Prevent premature exit in _WD_WaitElement
	- Fixed: ChromeDriver now uses goog:chromeOptions

	V0.1.0.15
	- Fixed: __WD_Post now suppports Unicode text
	- Changed: Add support for Unicode text to _WD_ElementAction's "value" option
	- Changed: Add support for BinaryFormat option to _WD_Option
	- Added: _WD_LoadWait

	V0.1.0.14
	- Fixed: Improve error handling in _WD_NewTab
	- Fixed: Screenshot option in _WD_Window
	- Fixed: Close handles in __WD_Get, __WD_Post, __WD_Delete

	V0.1.0.13
	- Fixed: Remove unsupported locator constants
	- Fixed: Return value of _WD_WaitElement
	- Changed: Add support for 'displayed' option in _WD_ElementAction (BigDaddyO)
	- Changed: Add $lVisible parameter to _WD_WaitElement
	- Changed: $_WD_DEBUG now defaults to $_WD_DEBUG_Info

	V0.1.0.12
	- Changed: Modified _WD_NewTab with timeout parameter
	- Fixed: Correctly set @error in _WD_ExecuteScript
	- Added: _WD_HighlightElement (Danyfirex)
	- Added: _WD_HighlightElements (Danyfirex)

	V0.1.0.11
	- Changed: Modified _WD_FindElement to use new global constant
	- Fixed: _WD_GetMouseElement JSON processing
	- Fixed: _WD_GetElementFromPoint JSON processing
	- Added: _WD_GetFrameCount (Decibel)
	- Added: _WD_IsWindowTop   (Decibel)
	- Added: _WD_FrameEnter    (Decibel)
	- Added: _WD_FrameLeave    (Decibel)

	V0.1.0.10
	- Changed: Add support for non-standard error codes in _WD_Alert
	- Changed: Detect non-present alert in _WD_Alert
	- Changed: __WD_Error coding
	- Fixed: Correctly set function error codes
	- Added: _WD_LastHTTPResult

	V0.1.0.9
	- Changed: Force command parameter to lowercase in _WD_Action
	- Changed: Enhanced error checking in _WD_FindElement
	- Added: _WD_GetMouseElement
	- Added: _WD_GetElementFromPoint

	V0.1.0.8
	- Changed: Improve error handling in _WD_Attach
	- Fixed: Missing "window" in URL for _WD_Window
	- Fixed: Header entry for _WD_Option
	- Added: Reference to Edge driver
	- Fixed: _WD_Window implementation of Maximize, Minimize, Fullscreen, & Screenshot
	- Removed: Normal option from _WD_Window
	- Added: Rect option to _WD_Window

	V0.1.0.7
	- Changed: Add $sOption parameter to _WD_Action
	- Changed: Implemented "Actions" command in _WD_Action
	- Changed: Improved error handling in _WD_FindElement
	- Added: _WD_WaitElement

	V0.1.0.6
	- Fixed: Missing variable declarations
	- Changed: _WD_Attach error handling

	V0.1.0.5
	- Changed: Switched to using _WinHttp functions
	- Added: _WD_LinkClickByText

	V0.1.0.4
	- Changed: Renamed core UDF functions
	- Changed: _WD_FindElement now returns multiple elements as an array instead of raw JSON

	V0.1.0.3
	- Fixed: Error constants
	- Changed: Renamed UDF files
	- Changed: Expanded _WDAlert functionality
	- Changed: Check for timeout in __WD_Post
	- Changed: Support parameters in _WDExecuteScript
	- Added: _WD_Attach function

	V0.1.0.2
	- Fixed: _WDWindow
	- Changed: Error constants (mLipok)
	- Added: Links to W3C documentation
	- Added: _WD_NewTab function

	V0.1.0.1
	- Initial release
#ce
#EndRegion Description

#Region Copyright
#cs
	* WD_Core.au3
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


#Region Global Constants
Global Const $__WDVERSION = "0.2.0.6"

Global Const $_WD_ELEMENT_ID = "element-6066-11e4-a52e-4f735466cecf"
Global Const $_WD_EmptyDict  = "{}"

Global Const $_WD_LOCATOR_ByCSSSelector = "css selector"
Global Const $_WD_LOCATOR_ByXPath = "xpath"
Global Const $_WD_LOCATOR_ByLinkText = "link text"
Global Const $_WD_LOCATOR_ByPartialLinkText = "partial link text"
Global Const $_WD_LOCATOR_ByTagName = "tag name"

Global Const $_WD_DefaultTimeout = 10000 ; 10 seconds

Global Enum _
		$_WD_DEBUG_None = 0, _ ; No logging to console
		$_WD_DEBUG_Error,    _ ; Error logging to console
		$_WD_DEBUG_Info        ; Full logging to console

Global Enum _
		$_WD_ERROR_Success = 0, _ ; No error
		$_WD_ERROR_GeneralError, _ ; General error
		$_WD_ERROR_SocketError, _ ; No socket
		$_WD_ERROR_InvalidDataType, _ ; Invalid data type (IP, URL, Port ...)
		$_WD_ERROR_InvalidValue, _ ; Invalid value in function-call
		$_WD_ERROR_InvalidArgue, _ ; Invalid argument in function-call
		$_WD_ERROR_SendRecv, _ ; Send / Recv Error
		$_WD_ERROR_Timeout, _ ; Connection / Send / Recv timeout
		$_WD_ERROR_NoMatch, _ ; No match for _WDAction-find/search _WDGetElement...
		$_WD_ERROR_RetValue, _ ; Error echo from Repl e.g. _WDAction("fullscreen","true") <> "true"
		$_WD_ERROR_Exception, _ ; Exception from web driver
		$_WD_ERROR_InvalidExpression, _ ; Invalid expression in XPath query or RegEx
		$_WD_ERROR_NoAlert, _ ; No alert present when calling _WD_Alert
		$_WD_ERROR_NotFound, _ ;
		$_WD_ERROR_COUNTER ;

Global Const $aWD_ERROR_DESC[$_WD_ERROR_COUNTER] = [ _
		"Success", _
		"General Error", _
		"Socket Error", _
		"Invalid data type", _
		"Invalid value", _
		"Invalid argument", _
		"Send / Recv error", _
		"Timeout", _
		"No match", _
		"Error return value", _
		"Webdriver Exception", _
		"Invalid Expression", _
		"No alert present", _
		"Not found" _
		]

Global Const $WD_Element_NotFound = "no such element"
Global Const $WD_Element_Stale = "stale element reference"
Global Const $WD_Element_Invalid = "invalid argument"

#EndRegion Global Constants


#Region Global Variables
Global $_WD_DRIVER = "" ; Path to web driver executable
Global $_WD_DRIVER_PARAMS = "" ; Parameters to pass to web driver executable
Global $_WD_BASE_URL = "HTTP://127.0.0.1"
Global $_WD_PORT = 0 ; Port used for web driver communication
Global $_WD_OHTTP = ObjCreate("winhttp.winhttprequest.5.1")
Global $_WD_HTTPRESULT ; Result of last WinHTTP request
Global $_WD_SESSION_DETAILS = "" ; Response from _WD_CreateSession
Global $_WD_BFORMAT = $SB_UTF8 ; Binary format
Global $_WD_ESCAPE_CHARS = '\\"' ; Characters to escape

Global $_WD_ERROR_MSGBOX = True ; Shows in compiled scripts error messages in msgboxes
Global $_WD_DEBUG = $_WD_DEBUG_Info ; Trace to console and show web driver app

#EndRegion Global Variables

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_CreateSession
; Description ...: Request new session from web driver
; Syntax ........: _WD_CreateSession([$sDesiredCapabilities = '{}'])
; Parameters ....: $sDesiredCapabilities- [optional] a string value. Default is '{}'.
; Return values .: Success      - Session ID to be used in future requests to web driver session
;                  Failure      - Empty string
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#new-session
; Example .......: No
; ===============================================================================================================================
Func _WD_CreateSession($sDesiredCapabilities = Default)
	Local Const $sFuncName = "_WD_CreateSession"
	Local $sSession = ""

	If $sDesiredCapabilities = Default Then $sDesiredCapabilities = $_WD_EmptyDict

	Local $sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session", $sDesiredCapabilities)
	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr = $_WD_ERROR_Success Then
		Local $oJSON = Json_Decode($sResponse)
		$sSession = Json_Get($oJSON, "[value][sessionId]")

		If @error Then
			Local $sMessage = Json_Get($oJSON, "[value][message]")

			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, $sMessage), $_WD_HTTPRESULT, "")
		EndIf
	Else
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, "")
	EndIf

	; Save response details for future use
	$_WD_SESSION_DETAILS = $sResponse

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sSession)
EndFunc   ;==>_WD_CreateSession


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_DeleteSession
; Description ...:  Delete existing session
; Syntax ........: _WD_DeleteSession($sSession)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
; Return values .: Success      - 1
;                  Failure      - 0
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#delete-session
; Example .......: No
; ===============================================================================================================================
Func _WD_DeleteSession($sSession)
	Local Const $sFuncName = "_WD_DeleteSession"

	Local $sResponse = __WD_Delete($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession)
	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, 1)
EndFunc   ;==>_WD_DeleteSession

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Status
; Description ...: Get current web driver state
; Syntax ........: _WD_Status()
; Parameters ....:
; Return values .: Success      - Raw JSON response from web driver
;                  Failure      - 0
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#status
; Example .......: No
; ===============================================================================================================================
Func _WD_Status()
	Local Const $sFuncName = "_WD_Status"
	Local $sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/status")
	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResponse)
EndFunc   ;==>_WD_Status


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Timeouts
; Description ...:  Set or retrieve the session timeout parameters
; Syntax ........: _WD_Timeouts($sSession[, $sTimeouts = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sTimeouts           - [optional] a string value. Default is ''.
; Return values .: Success      - Raw return value from web driver in JSON format
;                  Failure      - 0
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#get-timeouts
;                  https://www.w3.org/TR/webdriver#set-timeouts
; Example .......: No
; ===============================================================================================================================
Func _WD_Timeouts($sSession, $sTimeouts = Default)
	Local Const $sFuncName = "_WD_Timeouts"
	Local $sResponse, $sURL

	If $sTimeouts = Default Then $sTimeouts = ''

	$sURL = $_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/timeouts"

	If $sTimeouts = '' Then
		$sResponse = __WD_Get($sURL)
	Else
		$sResponse = __WD_Post($sURL, $sTimeouts)
	EndIf

	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResponse)
EndFunc   ;==>_WD_Timeouts


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Navigate
; Description ...: Navigate to the designated URL
; Syntax ........: _WD_Navigate($sSession, $sURL)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sURL                - Destination URL
; Return values .: Success      - 1
;                  Failure      - 0
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_Timeout
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#navigate-to
; Example .......: No
; ===============================================================================================================================
Func _WD_Navigate($sSession, $sURL)
	Local Const $sFuncName = "_WD_Navigate"
	Local $sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/url", '{"url":"' & $sURL & '"}')

	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $iErr, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, 1)
EndFunc   ;==>_WD_Navigate


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Action
; Description ...: Perform various interactions with the web driver session
; Syntax ........: _WD_Action($sSession, $sCommand[, $sOption = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sCommand            - one of the following actions:
;                               | refresh
;                               | back
;                               | forward
;                               | url
;                               | title
;                               | actions
;                  $sOption             - [optional] a string value. Default is ''.
; Return values .: Success      - Return value from web driver (could be an empty string)
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidDataType
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#navigation
;                  https://www.w3.org/TR/webdriver#actions
; Example .......: No
; ===============================================================================================================================
Func _WD_Action($sSession, $sCommand, $sOption = Default)
	Local Const $sFuncName = "_WD_Action"
	Local $sResponse, $sResult = "", $iErr, $oJSON, $sURL

	If $sOption = Default Then $sOption = ''

	$sCommand = StringLower($sCommand)
	$sURL = $_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/" & $sCommand

	Switch $sCommand
		Case 'back', 'forward', 'refresh'
			$sResponse = __WD_Post($sURL, $_WD_EmptyDict)
			$iErr = @error

		Case 'url', 'title'
			$sResponse = __WD_Get($sURL)
			$iErr = @error

			If $iErr = $_WD_ERROR_Success Then
				$oJSON = Json_Decode($sResponse)
				$sResult = Json_Get($oJSON, "[value]")
			EndIf

		Case 'actions'
			If $sOption <> '' Then
				$sResponse = __WD_Post($sURL, $sOption)
			Else
				$sResponse = __WD_Delete($sURL)
			EndIf

			$iErr = @error

		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Back|Forward|Refresh|Url|Title|Actions) $sCommand=>" & $sCommand), "")

	EndSwitch

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
EndFunc   ;==>_WD_Action

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Window
; Description ...: Perform interactions related to the current window
; Syntax ........: _WD_Window($sSession, $sCommand[, $sOption = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;
;                  $sCommand  - one of the following actions:
;                               | Window - Get current tab's window handle
;                               | Handles - Get all window handles
;                               | Maximize - Maximize window
;                               | Minimize - Minimize window
;                               | Fullscreen - Set window to fullscreen
;                               | Rect - Get or set the window's size & position
;                               | Screenshot - Take screenshot of window
;                               | Close - Close current tab
;                               | Switch - Switch to designated tab
;                               | Frame - Switch to frame
;                               | Parent - Switch to parent frame
;
;                  $sOption   - [optional] a string value. Default is ''.
;
; Return values .: Success      - Return value from web driver (could be an empty string)
;                  Failure      - ""
;
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidDataType
;                  @EXTENDED    - WinHTTP status code
;
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver/#contexts
; Example .......: No
; ===============================================================================================================================
Func _WD_Window($sSession, $sCommand, $sOption = Default)
	Local Const $sFuncName = "_WD_Window"
	Local $sResponse, $oJSON, $sResult = "", $iErr, $sErr

	If $sOption = Default Then $sOption = ''

	$sCommand = StringLower($sCommand)

	Switch $sCommand
		Case 'window'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/" & $sCommand)
			$iErr = @error

		Case 'handles'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window/" & $sCommand)
			$iErr = @error

		Case 'maximize', 'minimize', 'fullscreen'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window/" & $sCommand, $_WD_EmptyDict)
			$iErr = @error

		Case 'rect'
			If $sOption = '' Then
				$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window/" & $sCommand)
			Else
				$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window/" & $sCommand, $sOption)
			EndIf

			$iErr = @error

		Case 'screenshot'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/" & $sCommand)
			$iErr = @error

		Case 'close'
			$sResponse = __WD_Delete($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window")
			$iErr = @error

		Case 'switch'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/window", $sOption)
			$iErr = @error

		Case 'frame'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/frame", $sOption)
			$iErr = @error

		Case 'parent'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/frame/parent", $sOption)
			$iErr = @error

		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Window|Handles|Maximize|Minimize|Fullscreen|Rect|Screenshot|Close|Switch|Frame|Parent) $sCommand=>" & $sCommand), 0, "")

	EndSwitch

	If $iErr = $_WD_ERROR_Success Then
		If $_WD_HTTPRESULT = $HTTP_STATUS_OK Then

			Switch $sCommand
				Case 'maximize', 'minimize', 'fullscreen', 'close', 'switch', 'frame', 'parent'
					$sResult = $sResponse

				Case Else
					$oJson = Json_Decode($sResponse)
					$sResult = Json_Get($oJson, "[value]")
			EndSwitch

		ElseIf $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
			$oJson = Json_Decode($sResponse)
			$sErr = Json_Get($oJson, "[value][error]")
			$iErr = ($sErr == $WD_Element_Stale) ? $_WD_ERROR_NoMatch : $_WD_ERROR_Exception

		Else
			$iErr = $_WD_ERROR_Exception
		EndIf
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & StringLeft($sResponse, 100) & "..." & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
EndFunc   ;==>_WD_Window


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_FindElement
; Description ...: Find element(s) by designated strategy
; Syntax ........: _WD_FindElement($sSession, $sStrategy, $sSelector[, $sStartElement = ""[, $lMultiple = False]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sStrategy           - Locator strategy. See defined constant $_WD_LOCATOR_* for allowed values
;                  $sSelector           - Value to find
;                  $sStartElement       - [optional] a string value. Default is "".
;                  $lMultiple           - [optional] an unknown value. Default is False.
; Return values .: Success      - Element ID(s) returned by web driver
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_NoMatch
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#element-retrieval
; Example .......: No
; ===============================================================================================================================
Func _WD_FindElement($sSession, $sStrategy, $sSelector, $sStartElement = Default, $lMultiple = Default)
	Local Const $sFuncName = "_WD_FindElement"
	Local $sCmd, $sElement, $sResponse, $sResult, $iErr, $sErr
	Local $oJson, $oValues, $sKey, $iRow, $aElements[0]

	If $sStartElement = Default Then $sStartElement = ""
	If $lMultiple = Default Then $lMultiple = False

	$sCmd = ($lMultiple) ? 'elements' : 'element'
	$sElement = ($sStartElement == "") ? "" : "/element/" & $sStartElement
	$sSelector = __WD_EscapeString($sSelector)

	$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & $sElement & "/" & $sCmd, '{"using":"' & $sStrategy & '","value":"' & $sSelector & '"}')
	$iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		If $_WD_HTTPRESULT = $HTTP_STATUS_OK Then
			If $lMultiple Then

				$oJson = Json_Decode($sResponse)
				$oValues = Json_Get($oJson, '[value]')

				If UBound($oValues) > 0 Then
					$sKey = "[" & $_WD_ELEMENT_ID & "]"

					Dim $aElements[UBound($oValues)]

					For $oValue In $oValues
						$aElements[$iRow] = Json_Get($oValue, $sKey)
						$iRow += 1
					Next
				Else
					$iErr = $_WD_ERROR_NoMatch
				EndIf
			Else
				$oJson = Json_Decode($sResponse)

				$sResult = Json_Get($oJson, "[value][" & $_WD_ELEMENT_ID & "]")
			EndIf

		ElseIf $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
			$oJson = Json_Decode($sResponse)
			$sErr = Json_Get($oJson, "[value][error]")
			$iErr = ($sErr == $WD_Element_NotFound) ? $_WD_ERROR_NoMatch : $_WD_ERROR_Exception

		Else
			$iErr = $_WD_ERROR_Exception
		EndIf
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $iErr, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, ($lMultiple) ? $aElements : $sResult)
EndFunc   ;==>_WD_FindElement


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ElementAction
; Description ...: Perform action on desginated element
; Syntax ........: _WD_ElementAction($sSession, $sElement, $sCommand[, $sOption = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sElement            - Element ID from _WDFindElement
;                  $sCommand            - Action to be performed
;                  $sOption             - [optional] a string value. Default is ''.
; Return values .: Success      - Requested data returned by web driver
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_NoMatch
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidDataType
;                  				- $_WD_ERROR_InvalidExpression
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver/#state
;                  https://www.w3.org/TR/webdriver#element-interaction
; Example .......: No
; ===============================================================================================================================
Func _WD_ElementAction($sSession, $sElement, $sCommand, $sOption = Default)
	Local Const $sFuncName = "_WD_ElementAction"
	Local $sResponse, $sResult = '', $iErr, $oJson, $sErr

	If $sOption = Default Then $sOption = ''

	$sCommand = StringLower($sCommand)

	Switch $sCommand
		Case 'name', 'rect', 'text', 'selected', 'enabled', 'displayed', 'screenshot'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/element/" & $sElement & "/" & $sCommand)
			$iErr = @error

		Case 'active'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/element/" & $sCommand)
			$iErr = @error

		Case 'attribute', 'property', 'css'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/element/" & $sElement & "/" & $sCommand & "/" & $sOption)
			$iErr = @error

		Case 'clear', 'click'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/element/" & $sElement & "/" & $sCommand, '{"id":"' & $sElement & '"}')
			$iErr = @error

		Case 'value'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/element/" & $sElement & "/" & $sCommand, '{"id":"' & $sElement & '", "text":"' & __WD_EscapeString($sOption) & '"}')
			$iErr = @error

		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Name|Rect|Text|Selected|Enabled|Displayed|Active|Attribute|Property|CSS|Clear|Click|Value|Screenshot) $sCommand=>" & $sCommand), 0, "")

	EndSwitch

	If $iErr = $_WD_ERROR_Success Then
		Switch $_WD_HTTPRESULT
			Case $HTTP_STATUS_OK
				Switch $sCommand
					Case 'clear', 'click', 'value'
						$sResult = $sResponse

					Case Else
						$oJson = Json_Decode($sResponse)
						$sResult = Json_Get($oJson, "[value]")
				EndSwitch

			Case $HTTP_STATUS_NOT_FOUND
				$oJson = Json_Decode($sResponse)
				$sErr = Json_Get($oJson, "[value][error]")
				$iErr = ($sErr == $WD_Element_Stale) ? $_WD_ERROR_NoMatch : $_WD_ERROR_Exception

			Case $HTTP_STATUS_BAD_REQUEST
				$oJson = Json_Decode($sResponse)
				$sErr = Json_Get($oJson, "[value][error]")
				$iErr = ($sErr == $WD_Element_Invalid) ? $_WD_ERROR_InvalidArgue : $_WD_ERROR_Exception

			Case Else
				$iErr = $_WD_ERROR_Exception
		EndSwitch
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & StringLeft($sResponse,100) & "..." & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $iErr, $sResponse), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
EndFunc   ;==>_WD_ElementAction


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ExecuteScript
; Description ...: Execute Javascipt commands
; Syntax ........: _WD_ExecuteScript($sSession, $sScript[, $sArguments = "[]"[, $lAsync = False]])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sScript             - Javascript command(s) to run
;                  $sArguments          - [optional] String of arguments in JSON format
;                  $lAsync              - [optional] Perform request asyncronously? Default is False.
; Return values .: Raw response from web driver
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_Timeout
;                  				- $_WD_ERROR_SocketError
;                  				- $_WD_ERROR_InvalidValue
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#executing-script
; Example .......: No
; ===============================================================================================================================
Func _WD_ExecuteScript($sSession, $sScript, $sArguments = Default, $lAsync = Default)
	Local Const $sFuncName = "_WD_ExecuteScript"
	Local $sResponse, $sData, $sCmd

	If $sArguments = Default Then $sArguments = "[]"
	If $lAsync = Default Then $lAsync = False

	$sScript = __WD_EscapeString($sScript)

	$sData = '{"script":"' & $sScript & '", "args":[' & $sArguments & ']}'
	$sCmd = ($lAsync) ? 'async' : 'sync'

	$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/execute/" & $sCmd, $sData)

	Local $iErr = @error

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $iErr, "HTTP status = " & $_WD_HTTPRESULT), $_WD_HTTPRESULT, $sResponse)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResponse)


;~ 	Return SetError(($_WD_HTTPRESULT <> $HTTP_STATUS_OK) ? $_WD_ERROR_GeneralError : $_WD_ERROR_Success, $_WD_HTTPRESULT, $sResponse)
EndFunc   ;==>_WD_ExecuteScript


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Alert
; Description ...: Respond to user prompt
; Syntax ........: _WD_Alert($sSession, $sCommand[, $sOption = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sCommand            - one of the following actions:
;                               | dismiss
;                               | accept
;                               | gettext
;                               | sendtext
;                               | status
;                  $sOption             - [optional] a string value. Default is ''.
; Return values .: Success      - Requested data returned by web driver
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidDataType
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#user-prompts
; Example .......: No
; ===============================================================================================================================
Func _WD_Alert($sSession, $sCommand, $sOption = Default)
	Local Const $sFuncName = "_WD_Alert"
	Local $sResponse, $iErr, $oJSON, $sResult = ''

	If $sOption = Default Then $sOption = ''

	$sCommand = StringLower($sCommand)

	Switch $sCommand
		Case 'dismiss', 'accept'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/alert/" & $sCommand, $_WD_EmptyDict)
			$iErr = @error

			If $iErr = $_WD_ERROR_Success And $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
				$iErr = $_WD_ERROR_NoAlert
			EndIf

		Case 'gettext'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/alert/text")
			$iErr = @error

			If $iErr = $_WD_ERROR_Success Then
				If $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
					$sResult = ""
					$iErr = $_WD_ERROR_NoAlert
				Else
					$oJSON = Json_Decode($sResponse)
					$sResult = Json_Get($oJSON, "[value]")
				EndIf
			EndIf

		Case 'sendtext'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/alert/text", '{"text":"' & $sOption & '"}')
			$iErr = @error

			If $iErr = $_WD_ERROR_Success And $_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND Then
				$iErr = $_WD_ERROR_NoAlert
			EndIf

		Case 'status'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/alert/text")
			$iErr = @error

			If $iErr = $_WD_ERROR_Success Then
				$sResult = ($_WD_HTTPRESULT = $HTTP_STATUS_NOT_FOUND) ? False : True
			EndIf

		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Dismiss|Accept|GetText|SendText|Status) $sCommand=>" & $sCommand), 0, "")
	EndSwitch

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, $sResponse), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
EndFunc   ;==>_WD_Alert


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetSource
; Description ...: Get page source
; Syntax ........: _WD_GetSource($sSession)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
; Return values .: Success      - Source code from page
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#get-page-source
; Example .......: No
; ===============================================================================================================================
Func _WD_GetSource($sSession)
	Local Const $sFuncName = "_WD_GetSource"
	Local $sResponse, $iErr, $sResult = "", $oJSON

	$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/source")
	$iErr = @error

	If $iErr = $_WD_ERROR_Success Then
		$oJSON = Json_Decode($sResponse)
		$sResult = Json_Get($oJSON, "[value]")
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, $sResponse), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
	EndFunc   ;==>_WD_GetSource

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Cookies
; Description ...: Gets, sets, or deletes the session's cookies
; Syntax ........: _WD_Cookies($sSession, $sCommand[, $sOption = ''])
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;                  $sCommand            - one of the following actions:
;                               | Get
;                               | GetAll
;                               | Add
;                               | Delete
;                  $sOption             - [optional] a string value. Default is ''.
; Return values .: Success      - Requested data returned by web driver
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidDataType
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3.org/TR/webdriver#cookies
; Example .......: No
; ===============================================================================================================================
Func _WD_Cookies($sSession, $sCommand, $sOption = Default)
	Local Const $sFuncName = "_WD_Cookies"
	Local $sResult, $sResponse, $iErr

	If $sOption = Default Then $sOption = ''

	$sCommand = StringLower($sCommand)

	Switch $sCommand
		Case 'getall'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/cookie")
			$iErr = @error

			If $iErr = $_WD_ERROR_Success Then
				$sResult = $sResponse
			EndIf

		Case 'get'
			$sResponse = __WD_Get($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/cookie/" & $sOption)
			$iErr = @error

			If $iErr = $_WD_ERROR_Success Then
				$sResult = $sResponse
			EndIf

		Case 'add'
			$sResponse = __WD_Post($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/cookie", $sOption)
			$iErr = @error

		Case 'delete'
			$sResponse = __WD_Delete($_WD_BASE_URL & ":" & $_WD_PORT & "/session/" & $sSession & "/cookie/" & $sOption)
			$iErr = @error

		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(GetAll|Get|Add|Delete) $sCommand=>" & $sCommand), "")
	EndSwitch

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': ' & $sResponse & @CRLF)
	EndIf

	If $iErr Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, $sResponse), $_WD_HTTPRESULT, "")
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResult)
EndFunc   ;==>_WD_Cookies


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Option
; Description ...: Sets and get options for the web driver UDF
; Syntax ........: _WD_Option($sOption[, $vValue = ""])
; Parameters ....: $sOption             - a string value.
;                  $vValue              - [optional] a variant value. Default is "".
; Parameter(s): .: $sOption     - Driver - Full path name to web driver executable
;                               |DriverParams - Parameters to pass to web driver executable
;                               |BaseURL - IP address used for web driver communication
;                               |Port - Port used for web driver communication
;                               |BinaryFormat - Format used to store binary data
;                  $vValue      - Optional: (Default = "") : if no value is given, the current value is returned
; Return Value ..: Success      - 1 / current value
;                  Failure      - 0
;                  Failure      - ""
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_InvalidDataType
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_Option($sOption, $vValue = Default)
	Local Const $sFuncName = "_WD_Option"

	If $vValue = Default Then $vValue = ''

	Switch $sOption
		Case "Driver"
			If $vValue == "" Then Return $_WD_DRIVER
			If Not IsString($vValue) Then
				Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(string) $vValue: " & $vValue), 0, 0)
			EndIf
			$_WD_DRIVER = $vValue
		Case "DriverParams"
			If $vValue == "" Then Return $_WD_DRIVER_PARAMS
			If Not IsString($vValue) Then
				Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(string) $vValue: " & $vValue), 0, 0)
			EndIf
			$_WD_DRIVER_PARAMS = $vValue
		Case "BaseURL"
			If $vValue == "" Then Return $_WD_BASE_URL
			If Not IsString($vValue) Then
				Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(string) $vValue: " & $vValue), 0, 0)
			EndIf
			$_WD_BASE_URL = $vValue
		Case "Port"
			If $vValue == "" Then Return $_WD_PORT
			If Not IsInt($vValue) Then
				Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(int) $vValue: " & $vValue), 0, 0)
			EndIf
			$_WD_PORT = $vValue
		Case "BinaryFormat"
			If $vValue == "" Then Return $_WD_BFORMAT
			If Not IsInt($vValue) Then
				Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(int) $vValue: " & $vValue), 0, 0)
			EndIf
			$_WD_BFORMAT = $vValue
		Case Else
			Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidDataType, "(Driver|DriverParams|BaseURL|Port|BinaryFormat) $sOption=>" & $sOption), 0, 0)
	EndSwitch

	Return 1
EndFunc   ;==>_WD_Option

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Startup
; Description ...: Launch the designated web driver console app
; Syntax ........: _WD_Startup()
; Parameters ....: None
; Return values .: Success      - PID for the WD console
;                  Failure      - 0
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_GeneralError
;                  				- $_WD_ERROR_InvalidValue
;                  @EXTENDED    - WinHTTP status code
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_Startup()
	Local Const $sFuncName = "_WD_Startup"

	If $_WD_DRIVER = "" Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_InvalidValue, "Location for Web Driver not set." & @CRLF), 0, 0)
	EndIf

	__WD_CloseDriver()

	Local $sCommand = StringFormat('"%s" %s ', $_WD_DRIVER, $_WD_DRIVER_PARAMS)

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite("_WDStartup: OS:" & @TAB & @OSVersion & " " & @OSType & " " & @OSBuild & " " & @OSServicePack & @CRLF)
		ConsoleWrite("_WDStartup: AutoIt:" & @TAB & @AutoItVersion & @CRLF)
		ConsoleWrite("_WDStartup: WD.au3:" & @TAB & $__WDVERSION & @CRLF)
		ConsoleWrite("_WDStartup: WinHTTP:" & @TAB & __WinHttpVer() & @CRLF)
		ConsoleWrite("_WDStartup: Driver:" & @TAB & $_WD_DRIVER & @CRLF)
		ConsoleWrite("_WDStartup: Params:" & @TAB & $_WD_DRIVER_PARAMS & @CRLF)
		ConsoleWrite("_WDStartup: Port:" & @TAB & $_WD_PORT & @CRLF)
	Else
		ConsoleWrite('_WDStartup: ' & $sCommand & @CRLF)
	EndIf

	Local $pid = Run($sCommand, "", ($_WD_DEBUG = $_WD_DEBUG_Info) ? @SW_SHOW : @SW_HIDE)

	If @error Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_GeneralError, "Error launching web driver!"), 0, 0)
	EndIf

	Return SetError($_WD_ERROR_Success, 0, $pid)
EndFunc   ;==>_WD_Startup


; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Shutdown
; Description ...: Kill the web driver console app
; Syntax ........: _WD_Shutdown()
; Parameters ....:
; Return values .: None
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WD_Shutdown()
	__WD_CloseDriver()
EndFunc   ;==>_WD_Shutdown



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_Get
; Description ...: Submit GET request to WD console app
; Syntax ........: __WD_Get($sURL)
; Parameters ....: $sURL        -
; Return Value ..: Success      - Response from web driver
;                  Failure      - Response from web driver and set @ERROR
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
Func __WD_Get($sURL)
	Local Const $sFuncName = "__WD_Get"
	Local $iResult = $_WD_ERROR_Success, $sResponseText, $iErr

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': URL=' & $sURL & @CRLF)
	EndIf

	$_WD_HTTPRESULT = 0

	Local $aURL = _WinHttpCrackUrl($sURL)

	If IsArray($aURL) Then
		; Initialize and get session handle
		Local $hOpen = _WinHttpOpen()

		; Get connection handle
		Local $hConnect = _WinHttpConnect($hOpen, $aURL[2], $aURL[3])

		If @error Then
			$iResult = $_WD_ERROR_SocketError
		Else
			Switch $aURL[1]
				Case $INTERNET_SCHEME_HTTP
					$sResponseText = _WinHttpSimpleRequest($hConnect, "GET", $aURL[6] & $aURL[7])
				Case $INTERNET_SCHEME_HTTPS
					$sResponseText = _WinHttpSimpleSSLRequest($hConnect, "GET", $aURL[6] & $aURL[7])
				Case Else
					SetError($_WD_ERROR_InvalidValue)
			EndSwitch

			$iErr = @error
			$_WD_HTTPRESULT = @extended

			If $iErr Then
				$iResult = $_WD_ERROR_SendRecv
			; Remove $HTTP_STATUS_REQUEST_TIMEOUT check once Chromedriver is updated
			ElseIf $_WD_HTTPRESULT =  $HTTP_STATUS_SERVER_ERROR Or $_WD_HTTPRESULT = $HTTP_STATUS_REQUEST_TIMEOUT Then
				$iResult = $_WD_ERROR_Timeout
			EndIf
		EndIf

		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
	Else
		$iResult = $_WD_ERROR_InvalidValue
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': StatusCode=' & $_WD_HTTPRESULT & "; $iResult = " & $iResult & "; $sResponseText=" & StringLeft($sResponseText,100) & "..." & @CRLF)
	EndIf

	If $iResult Then
		Return SetError(__WD_Error($sFuncName, $iResult, $sResponseText), $_WD_HTTPRESULT, $sResponseText)
	EndIf

	Return SetError($_WD_ERROR_Success, 0, $sResponseText)
EndFunc   ;==>__WD_Get


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_Post
; Description ...: Submit POST request to WD console app
; Syntax ........: __WD_Post($sURL, $sData)
; Parameters ....: $sURL                - a string value.
;                  $sData               - a string value.
; Return Value ..: Success      - Response from web driver
;                  Failure      - Response from web driver and set @ERROR
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_Timeout
;                  				- $_WD_ERROR_SocketError
;                  				- $_WD_ERROR_InvalidValue
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WD_Post($sURL, $sData)
	Local Const $sFuncName = "__WD_Post"
	Local $iResult, $sResponseText, $iErr

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': URL=' & $sURL & "; $sData=" & $sData & @CRLF)
	EndIf

	$_WD_HTTPRESULT = 0

	Local $aURL = _WinHttpCrackUrl($sURL)

	If @error Then
		$iResult = $_WD_ERROR_InvalidValue
	Else
		; Initialize and get session handle
		Local $hOpen = _WinHttpOpen()

		; Get connection handle
		Local $hConnect = _WinHttpConnect($hOpen, $aURL[2], $aURL[3])

		If @error Then
			$iResult = $_WD_ERROR_SocketError
		Else
			Switch $aURL[1]
				Case $INTERNET_SCHEME_HTTP
					$sResponseText = _WinHttpSimpleRequest($hConnect, "POST", $aURL[6] & $aURL[7], Default, StringToBinary($sData, $_WD_BFORMAT))
				Case $INTERNET_SCHEME_HTTPS
					$sResponseText = _WinHttpSimpleSSLRequest($hConnect, "POST", $aURL[6] & $aURL[7], Default, StringToBinary($sData, $_WD_BFORMAT))
				Case Else
					SetError($_WD_ERROR_InvalidValue)
			EndSwitch

			$iErr = @error
			$_WD_HTTPRESULT = @extended

			If $iErr Then
				$iResult = $_WD_ERROR_SendRecv
			; Remove $HTTP_STATUS_REQUEST_TIMEOUT check once Chromedriver is updated
			ElseIf $_WD_HTTPRESULT =  $HTTP_STATUS_SERVER_ERROR Or $_WD_HTTPRESULT = $HTTP_STATUS_REQUEST_TIMEOUT Then
				$iResult = $_WD_ERROR_Timeout
			EndIf
		EndIf

		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': StatusCode=' & $_WD_HTTPRESULT & "; ResponseText=" & $sResponseText & @CRLF)
	EndIf

	If $iResult Then
		Return SetError(__WD_Error($sFuncName, $iResult, $sResponseText), $_WD_HTTPRESULT, $sResponseText)
	EndIf

	Return SetError($_WD_ERROR_Success, $_WD_HTTPRESULT, $sResponseText)
EndFunc   ;==>__WD_Post


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_Delete
; Description ...: Submit DELETE request to WD console app
; Syntax ........: __WD_Delete($sURL)
; Parameters ....: $sURL        -
; Return Value ..: Success      - Response from web driver
;                  Failure      - Response from web driver and set @ERROR
;                  @ERROR       - $_WD_ERROR_Success
;                  				- $_WD_ERROR_Exception
;                  				- $_WD_ERROR_InvalidValue
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WD_Delete($sURL)
	Local Const $sFuncName = "__WD_Delete"

	Local $iResult, $sResponseText, $iErr

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': URL=' & $sURL & @CRLF)
	EndIf

	$_WD_HTTPRESULT = 0

	Local $aURL = _WinHttpCrackUrl($sURL)

	If @error Then
		$iResult = $_WD_ERROR_InvalidValue
	Else
		; Initialize and get session handle
		Local $hOpen = _WinHttpOpen()

		; Get connection handle
		Local $hConnect = _WinHttpConnect($hOpen, $aURL[2], $aURL[3])

		If @error Then
			$iResult = $_WD_ERROR_SocketError
		Else
			Switch $aURL[1]
				Case $INTERNET_SCHEME_HTTP
					$sResponseText = _WinHttpSimpleRequest($hConnect, "DELETE", $aURL[6] & $aURL[7])
				Case $INTERNET_SCHEME_HTTPS
					$sResponseText = _WinHttpSimpleSSLRequest($hConnect, "DELETE", $aURL[6] & $aURL[7])
				Case Else
					SetError($_WD_ERROR_InvalidValue)
			EndSwitch

			$iErr = @error
			$_WD_HTTPRESULT = @extended

			If $iErr Then
				$iResult = $_WD_ERROR_SendRecv
			; Remove $HTTP_STATUS_REQUEST_TIMEOUT check once Chromedriver is updated
			ElseIf $_WD_HTTPRESULT =  $HTTP_STATUS_SERVER_ERROR Or $_WD_HTTPRESULT = $HTTP_STATUS_REQUEST_TIMEOUT Then
				$iResult = $_WD_ERROR_Timeout
			EndIf
		EndIf

		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
	EndIf

	If $_WD_DEBUG = $_WD_DEBUG_Info Then
		ConsoleWrite($sFuncName & ': StatusCode=' & $_WD_HTTPRESULT & "; ResponseText=" & $sResponseText & @CRLF)
	EndIf

	If $iResult Then
		Return SetError(__WD_Error($sFuncName, $_WD_ERROR_Exception, $sResponseText), $_WD_HTTPRESULT, $sResponseText)
	EndIf

	Return SetError($_WD_ERROR_Success, 0, $sResponseText)
EndFunc   ;==>__WD_Delete


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_Error
; Description ...: Writes Error to the console and show message-boxes if the script is compiled
; Syntax ........: __WD_Error($sWhere, $i_WD_ERROR[, $sMessage = ""])
; Parameters ....: $sWhere              - Name of calling routine
;                  $i_WD_ERROR          - Error constant
;                  $sMessage            - [optional] (Default = "") : Additional Information
; Return values .: Success      - Error Const from $i_WD_ERROR
; Author ........: Thorsten Willert, Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WD_Error($sWhere, $i_WD_ERROR, $sMessage = Default)
	Local $sMsg

	If $sMessage = Default Then $sMessage = ''

	Switch $_WD_DEBUG
		Case $_WD_DEBUG_None

		Case $_WD_DEBUG_Error
			If $i_WD_ERROR <> $_WD_ERROR_Success Then ContinueCase

		Case $_WD_DEBUG_Info
			$sMsg = $sWhere & " ==> " & $aWD_ERROR_DESC[$i_WD_ERROR]

			If $sMessage <> "" Then
				$sMsg = $sMsg & ": " & $sMessage
			EndIf

			ConsoleWrite($sMsg & @CRLF)

			If @Compiled Then
				If $_WD_ERROR_MSGBOX And $i_WD_ERROR <> $_WD_ERROR_Success And $i_WD_ERROR < 6 Then MsgBox(16, "WD_Core.au3 Error:", $sMsg)
				DllCall("kernel32.dll", "none", "OutputDebugString", "str", $sMsg)
			EndIf
	EndSwitch

	Return $i_WD_ERROR
EndFunc ;==>__WD_Error


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_CloseDriver
; Description ...: Shutdown web driver console if it exists
; Syntax ........: __WD_CloseDriver([$sDriver = Default])
; Parameters ....: $sDriver             - [optional] Web driver console to shutdown. Default is $_WD_DRIVER
; Return values .: None
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WD_CloseDriver($sDriver = Default)
	Local $sFile, $iID, $aData

	If $sDriver = Default Then $sDriver = $_WD_DRIVER

	$sFile = StringRegExpReplace($sDriver, "^.*\\(.*)$", "$1")

	Do
		$iID = ProcessExists($sFile)

		If $iID Then
			$aData = _WinAPI_EnumChildProcess($iID)

			If IsArray($aData) Then
				For $i = 0 To UBound($aData) - 1
					If $aData[$i][1] = 'conhost.exe' Then
						ProcessClose($aData[$i][0])
					EndIf
				Next
			EndIf

			ProcessClose($iID)
		EndIf
	Until Not $iID

EndFunc ;==>__WD_CloseDriver

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __WD_EscapeString
; Description ...: Escapes designated characters in string
; Syntax ........: __WD_EscapeString($sData)
; Parameters ....: $sData               - the string to be escaped
; Return Value ..: Success      - Escaped string
;                  @ERROR       - $_WD_ERROR_Success
; Return values .: None
; Author ........: Dan Pollak
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WD_EscapeString($sData)
	Local $sRegEx = "([" & $_WD_ESCAPE_CHARS & "])"
	Local $sEscaped = StringRegExpReplace($sData, $sRegEx, "\\$1")
	Return SetError($_WD_ERROR_Success, 0, $sEscaped)
EndFunc

Func __WD_TranslateQuotes($sData)
	Local $sResult = StringReplace($sData, '"' , "'")
	Return SetError($_WD_ERROR_Success, 0, $sResult)
EndFunc
