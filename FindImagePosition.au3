;~ #include <GUIConstantsEx.au3>
;~ #include <ScreenCapture.au3>
;~ local $TIF_FILENAME="E:\temp\test.tif"
;~ Local $TESS_PARAMS= $TIF_FILENAME & " " & "E:\temp\text" @DesktopWidth - 825- 56
;~ Local $TESS_EXE= @ProgramFilesDir & "\Tesseract-OCR\tesseract.exe"
;~ local $TWorkDir="E:\temp\"  @DesktopHeight - 487
;~ Local $iScale = 8.0 ;1.0 is without any scaling

#include <WindowsConstants.au3>
#include <File.au3>                                     ;Required to create a unique ~temp file
#include <ScreenCapture.au3>                            ;Required to capture image

Global $aOCR_IMG_ORI                                    ;Global Var that will store the location of the image that was taken to perform OCR on
Global $tesseract_temp_path = @TempDir & "\"            ;Location of the image that is taken, and the .tsv file that is generated from that
Global $tesseract_path = "C:\Program Files\Tesseract-OCR\" ;Need to have the Tesseract-OCR folder in the sub-folder of the script thats running
;~ Global $sPath, $aFileName
;~ WinActivate("BlueStacks")
;~ Sleep(2000)
;~ Global $aposs = ControlGetPos("BlueStacks", "","[CLASS:BlueStacksApp; INSTANCE:1]" )
;~ MouseClickDrag($MOUSE_CLICK_LEFT, 500, 500, 1000, 500,60)
;~ $aTSV = _TesseractCaptureText("BlueStacks", "", "[CLASS:BlueStacksApp; INSTANCE:1]", " -l vie", 2, 830, 520,  1675, 1000, 1, 1)
;~ $aCoords = _TesseractFindCoords($aTSV, "Thăm", 0, 1, 2)
;~ MouseClick($aCoords[0] + $aOCR_IMG_ORI[0] - 90 , $aCoords[1] + $aOCR_IMG_ORI[1] - 50)
;~ ConsoleWrite($aCoords[0] & " - " & $aCoords[1] & " hello")
;;For this example, you will browse to a folder and select a file.  that files name will be the text to search for
;;  That files location will then be opened in Windows Explorer and OCR will be performed on that to find the file within that folder
;;   Note:  file name must be visible to find so pick a folder without too many files or file names that are longer than can be displayed

;; Pick file(s) to OCR find within Explorer
 ;   $sFile = FileOpenDialog("Pick a file", @ScriptDir, "All (*.*)", 4)

 ;   $aFiles = StringSplit($sFile, "|")
 ;  If $aFiles[0] > 1 Then
  ;      ;Multiple files were selected.
   ;     ;[1] will contain the folder
    ;    ;[2]+ will contain the individual files
     ;   Global $aFileName[$aFiles[0] - 1]
    ;    $sPath = $aFiles[1] & "\"
    ;    For $i = 2 to $aFiles[0]
    ;        $aFileName[$i - 2] = $aFiles[$i]
    ;    Next
 ;   Else
 ;       ;Only 1 file was selected, split it up into parts so the array will be setup same as if multiple files were selected
 ;       Local $sDrive, $sDir, $sFileName, $sExtension
 ;       $aPathSplit = _PathSplit($sFile, $sDrive, $sDir, $sFileName, $sExtension)
 ;       $sPath = $sDrive & $sDir
 ;       Global $aFileName[1]  = [$sFileName & $sExtension]
 ;   EndIf


 ;   SplashTextOn("MyOCR_Example", "This can take a few minutes..." & @CRLF & "Opening Location", 500, 40, 0, 0)
 ;   ShellExecute($sPath, "open")
;
;    WinWaitActive("[CLASS:CabinetWClass]", StringLeft($sPath, StringLen($sPath) - 1), 15)   ;Wait until WinExplorer is opened
;    ControlSetText("MyOCR_Example", "", "Static1", "Found WinExplorer")
;	Sleep(600)
;;Capture all text from the main area of Windows Explorer
;    ControlSetText("MyOCR_Example", "", "Static1", "Getting all text")
;    $aTSV = _TesseractCaptureText("[CLASS:CabinetWClass]", "", "[CLASS:DirectUIHWND; INSTANCE:3]", 2, 0, 0, 0, 0, 1, 1)     ;Capture text from the explorer item within windows explorer

;;From the captured text, find what we are looking for
;;Must not do anything that would cause screen refreshes in the loop or before taking screenshot as that can erase redaction, ControlSetText in SplashText can break it too...
;For $i = 0 to UBound($aFileName) - 1

 ;   $sFileName = StringLeft($aFileName[$i], StringInStr($aFileName[$i], ".", 0, -1) - 1)    ;Strip off the Extension since some systems hide extensions

 ;   ConsoleWrite("Looking for " & $sFileName)
 ;   $aCoords = _TesseractFindCoords($aTSV, $sFileName, 0, 1, 2)     ;Returns x,y,w,h of requested text

 ;   ConsoleWrite(@TAB & "Drawing a black line from " & $aOCR_IMG_ORI[0] + $aCoords[0] & "," & $aOCR_IMG_ORI[1] + $aCoords[1] & " to " & $aCoords[2] & "," & $aCoords[3] & @CRLF)
 ;   _Redact($aOCR_IMG_ORI[0] + $aCoords[0], $aOCR_IMG_ORI[1] + $aCoords[1], $aCoords[2], $aCoords[3], 0x000000) ;Black out/Redact the selected text

;Next

;;Now that everything is redacted, take the screenshot
;$hwnd2 = ControlGetHandle("[CLASS:CabinetWClass]", "", "[CLASS:DirectUIHWND; INSTANCE:3]")
;_ScreenCapture_CaptureWnd(@ScriptDir & "\Redacted.jpg", $hwnd2)


;MsgBox(0, "", "Redacted" & @CRLF & "Click OK to display screenshot")
;ShellExecute(@ScriptDir & "\Redacted.jpg")



;===============================================================================
; Name...........:  _TesseractFindCoords()
; Description ...:  Retreives the Coordinates for specific text from the text returned by a Tesseract OCR TSV function
; Syntax.........:  _TesseractFindCoords($aTSV, $sFind, $iFindType = 0, $iMatch = 1)
; Parameters ....:  $aTSV               - Array returned from one of the _Tesseract-CapturePOS() functions
;                   $sFind              - String value of the text to find, spacing will be ignored as Tesseract seperates array by words ignoring spaces.
;                   $iFindType          - How to search for the text
;                                           0 = Contains anywhere (StringInStr) (default)
;                                           1 = Starts with (StringLeft)
;                                           2 = Ends with   (StringRight)
;                                           3 = Exact Match (=)
;                   $iMatch             - If multiple matches may exist, which of them do we want to return
;                                           1 = Return the first one we find (default)
;                                           -1 = Return the last one we find
;                                           # = Return the # item that we find
;                   $scale              - This must be the same scale as used in the _TesseractCaptureText() function as it will be used to adjust the coordinates
;
;                                       2nd to last Column = conf.  Confidence % that it's actually the word, may want to incorporate this as an additional option
;
; Return values .:  On Success  - Returns an array of coordinates for the matched text.
;                   On Failure  - Sets @error, returns empty array
;
; Author ........:  BigDaddyO
; Modified.......:
;
; Remarks .......:  Array returned from the _TesseractCaptureText() functions contains the text and their location
;                   This function finds the $sFind text within that array.
;                   Note:   All text from the image is broken down into individual words, so if the $sFind contains any spaces then it will
;                           be split up into an array itself and will be matched as concurrent items in the array.
;                           The Coordinates of each word are then added together to make coords for a single box including calculated space width
;
; Related .......:  Requires Tesseract 3.05+ to use TSV commandline option
; Link ..........:
; Example .......:
;==========================================================================================
Func _TesseractFindCoords($aTSV, $sTextToFind, $iFindType = 0, $iMatch = 1, $scale = 2)

    If $iMatch = 0 Then
        ConsoleWrite("Error, $iMatch 0 is not valid" & @CRLF)
        Return SetError(1)
    EndIf

    local $aCoords[4]                                                       ;Create the array that will store the coordinates
    Local $iFoundCount = 0

    $sTextToFind = StringStripWS($sTextToFind, 7)                           ;Remove any Trailing, leading, or double spaces so it will split and match up properly

    If $sTextToFind = "" Then
        ConsoleWrite("Error, the $sTextToFind is empty" & @CRLF)
        Return SetError(1, 0, $aCoords)
    EndIf

    If IsArray($aTSV) = 0 Then
        ConsoleWrite("Error, $aTSV is not an array" & @CRLF)
        Return SetError(1, 0, $aCoords)
    EndIf

    If UBound($aTSV, 2) <> 12 Then
        ConsoleWrite("OCR Text array size = ([" & UBound($aTSV) & "][" & UBound($aTSV, 2) & "]), does not match the expected [#][12].  Ensure you have the $tsv flag set to 1 in the _TesseractCaptureText() Function" & @CRLF)
        Return SetError(2, 0, $aCoords)
    EndIf

    $aSearchText = StringSplit($sTextToFind, " ")                           ;Split up the $sTextToFind into individual words as Tesseract stores them

    Switch $iFindType
        Case 0                                                              ;Looks anywhere for the word/sentence to start and end, words within a sentence must be exact

            For $i = 1 to UBound($aTSV) - 1                                 ;Search the contents of the OCR text array

                If $aSearchText[0] > 1 Then                                 ;This is a sentence, not just a word, so ensure this ends with the first word, not just InStr
                    If StringRight($aTSV[$i][11], StringLen($aSearchText[1])) <> $aSearchText[1] Then
                        ContinueLoop                                        ;This is not the text we are looking for
                    EndIf
                Else                                                        ;Looking for just a single word, so it could be anywhere
                    If StringInStr($aTSV[$i][11], $aSearchText[1]) = 0 Then
                        ContinueLoop                                        ;This is not the text we are looking for
                    EndIf
                EndIf

                Local $aTmpCoords[4]                                        ;Create array to store the coords until we are sure it's a full match
                Local $iFoundAt = $i                                        ;Save the # we found the first word at, incase this isn't the whole sentence
                Local $iCount = 0                                           ;Used to count the current word in the search text array we are on

                For $t = $i to $i + ($aSearchText[0] - 1)                   ;Looks like this is what we want, verify everything matches.

                    $iCount += 1
                    Select

                        Case $iCount = $aSearchText[0]                      ;This is the last word in the text we are looking for

                            If $iCount = 1 Then                             ;If this is actually the first & last then we need to save the Coords directly

                                If StringInStr($aTSV[$t][11], $aSearchText[($t - $iFoundAt) + 1]) Then  ;This is the first & Last word to find, so do an InStr
                                    $aTmpCoords[0] = $aTSV[$t][6]           ;Save the left value into the Temp Coords array
                                    $aTmpCoords[1] = $aTSV[$t][7]           ;Save the Top value into the Temp Coords array
                                    $aTmpCoords[2] = $aTSV[$t][8]           ;Save the Width value into the Temp Coords array
                                    $aTmpCoords[3] = $aTSV[$t][9]           ;Save the Height value into the Temp Coords array
                                Else
                                    ContinueLoop(2)                         ;not found, so continue looking for full match
                                EndIf

                            Else                                            ;This is the last but not the first, so we need to do a StringLeft instead of InStr to ensure the sentence is continues.

                                If StringLeft($aTSV[$t][11], StringLen($aSearchText[($t - $iFoundAt) + 1])) = $aSearchText[($t - $iFoundAt) + 1] Then
                                    If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                    $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                    If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                Else
                                    ContinueLoop(2)
                                EndIf

                            EndIf

                            $iFoundCount += 1                               ;This is a full match, so Increase the successful match by 1

                            $aCoords[0] = $aTmpCoords[0]                    ;Save the Temp Coordinates
                            $aCoords[1] = $aTmpCoords[1]
                            $aCoords[2] = $aTmpCoords[2]
                            $aCoords[3] = $aTmpCoords[3]

                            If $iMatch = $iFoundCount Then                  ;See if this is the match we want, defaults to the first match found
                                ;If there are multiple words, need to identify how many pixels to include where the spaces should have been
                                If $aSearchText[0] > 1 Then
                                    $iSpace = $aTSV[$t][8] / StringLen($aTSV[$t][11])   ;Get width of this word, then divide by the character length to get pixels per character
                                    $sTxtOnly = StringStripWS($sTextToFind, 8)
                                    $iSpace = $aCoords[2] / StringLen($sTxtOnly)        ;Divide the total width by the number of characters to get Pixels per character
                                    $aCoords[2] += ($iSpace * ($aSearchText[0] - 1))
                                EndIf

                                ;Convert the coordinates to onscreen coords according to the scale
                                $aCoords[0] = $aCoords[0] / $scale
                                $aCoords[1] = $aCoords[1] / $scale
                                $aCoords[2] = $aCoords[2] / $scale
                                $aCoords[3] = $aCoords[3] / $scale
                                Return $aCoords
                            Else
                                ContinueLoop(2)                             ;We found the full search text, but we don't want this one.
                            EndIf


                        Case $iCount = 1
                            If $aSearchText[0] > 1 Then                     ;This is a sentence, not just a word, so ensure this ends with the first word, not just InStr
                                If StringRight($aTSV[$t][11], StringLen($aSearchText[($t - $iFoundAt) + 1])) <> $aSearchText[($t - $iFoundAt) + 1] Then
                                    ContinueLoop(2)                         ;This is not the text we are looking for
                                EndIf
                            Else
                                If StringInStr($aTSV[$t][11], $aSearchText[($t - $iFoundAt) + 1]) = 0 Then
                                    ContinueLoop(2)                         ;This is not the text we are looking for
                                EndIf
                            EndIf
                            $aTmpCoords[0] = $aTSV[$t][6]                   ;Save the left value into the Temp Coords array
                            $aTmpCoords[1] = $aTSV[$t][7]                   ;Save the top value into the Temp Coords array
                            $aTmpCoords[2] = $aTSV[$t][8]                   ;Save the width value into the Temp Coords array
                            $aTmpCoords[3] = $aTSV[$t][9]                   ;Save the height value into the Temp Coords array
                            ContinueLoop                                    ;Look for the next word


                        Case Else                                           ;This is a middle word in the search text, so do an =
                            If $aTSV[$t][11] = $aSearchText[$t - $iFoundAt + 1] Then
                                ;Leave the [0] coord as-is
                                If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                ContinueLoop                                ;Possible that there is only 1 search word, so need to continue loop so the Start and End don't get triggered
                            Else
                                $i = $iFoundAt
                                ContinueLoop(2)                             ;if we didn't find the last word in the search text, start the search over
                            EndIf

                    EndSelect

                Next

            Next


        Case 1      ;The word/sentence starts with the specified text
            For $i = 1 to UBound($aTSV) - 1                                 ;Search the contents of the OCR text array

                If $aSearchText[0] > 1 Then                                 ;This is a sentence, not just a word, so ensure the entire first word matches
                    If $aTSV[$i][11] <> $aSearchText[1] Then
                        ContinueLoop
                    EndIf
                Else                                                        ;Looking for just a single word, so ensure it starts with this
                    If StringLeft($aTSV[$i][11], StringLen($aSearchText[1])) <> $aSearchText[1] Then
                        ContinueLoop                                        ;This is not the text we are looking for
                    EndIf
                EndIf

                Local $aTmpCoords[4]                                        ;Create array to store the coords until we are sure it's a full match
                Local $iFoundAt = $i                                        ;Save the # we found the first word at, incase this isn't the whole sentence
                Local $iCount = 0                                           ;Used to count the current word in the search text array we are on

                For $t = $i to $i + ($aSearchText[0] - 1)                   ;Looks like this is what we want, verify everything matches.

                    $iCount += 1
                    Select

                        Case $iCount = $aSearchText[0]                      ;This is the last word in the text we are looking for

                            If $iCount = 1 Then                             ;If this is actually the first & last then we need to save the Coords directly

                                If StringLeft($aTSV[$i][11], StringLen($aSearchText[1])) = $aSearchText[($t - $iFoundAt) + 1] Then  ;This is the first & Last word to find, so ensure it starts with
                                    $aTmpCoords[0] = $aTSV[$t][6]           ;Save the left value into the Temp Coords array
                                    $aTmpCoords[1] = $aTSV[$t][7]           ;Save the Top value into the Temp Coords array
                                    $aTmpCoords[2] = $aTSV[$t][8]           ;Save the Width value into the Temp Coords array
                                    $aTmpCoords[3] = $aTSV[$t][9]           ;Save the Height value into the Temp Coords array
                                Else
                                    ContinueLoop(2)                         ;not found, so continue looking for full match
                                EndIf

                            Else                                            ;This is the last but not the first, so we need to do a StringLeft to ensure the sentence is continues.

                                If StringLeft($aTSV[$t][11], StringLen($aSearchText[($t - $iFoundAt) + 1])) = $aSearchText[($t - $iFoundAt) + 1] Then
                                    If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                    $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                    If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                Else
                                    ContinueLoop(2)
                                EndIf

                            EndIf

                            $iFoundCount += 1                               ;This is a full match, so Increase the successful match by 1

                            $aCoords[0] = $aTmpCoords[0]                    ;Save the Temp Coordinates
                            $aCoords[1] = $aTmpCoords[1]
                            $aCoords[2] = $aTmpCoords[2]
                            $aCoords[3] = $aTmpCoords[3]

                            If $iMatch = $iFoundCount Then                  ;See if this is the match we want, defaults to the first match found
                                ;If there are multiple words, need to identify how many pixels to include where the spaces should have been
                                If $aSearchText[0] > 1 Then
                                    $iSpace = $aTSV[$t][8] / StringLen($aTSV[$t][11])   ;Get width of this word, then divide by the character length to get pixels per character
                                    $sTxtOnly = StringStripWS($sTextToFind, 8)
                                    $iSpace = $aCoords[2] / StringLen($sTxtOnly)        ;Divide the total width by the number of characters to get Pixels per character
                                    $aCoords[2] += ($iSpace * ($aSearchText[0] - 1))
                                EndIf

                                ;Convert the coordinates to onscreen coords according to the scale
                                $aCoords[0] = $aCoords[0] / $scale
                                $aCoords[1] = $aCoords[1] / $scale
                                $aCoords[2] = $aCoords[2] / $scale
                                $aCoords[3] = $aCoords[3] / $scale
                                Return $aCoords
                            Else
                                ContinueLoop(2)                             ;We found the full search text, but we don't want this one.
                            EndIf


                        Case $iCount = 1
                            If $aSearchText[0] > 1 Then                     ;This is a sentence, not just a word, so ensure this matches the first word exactly
                                If $aTSV[$t][11] <> $aSearchText[($t - $iFoundAt) + 1] Then
                                    ContinueLoop(2)                         ;This is not the text we are looking for
                                EndIf
                            Else
                                If StringLeft($aTSV[$t][11], StringLen($aSearchText[($t - $iFoundAt) + 1])) <> $aSearchText[($t - $iFoundAt) + 1] Then
                                    ContinueLoop(2)                         ;This is not the text we are looking for
                                EndIf
                            EndIf
                            $aTmpCoords[0] = $aTSV[$t][6]                   ;Save the left value into the Temp Coords array
                            $aTmpCoords[1] = $aTSV[$t][7]                   ;Save the top value into the Temp Coords array
                            $aTmpCoords[2] = $aTSV[$t][8]                   ;Save the width value into the Temp Coords array
                            $aTmpCoords[3] = $aTSV[$t][9]                   ;Save the height value into the Temp Coords array
                            ContinueLoop                                    ;Look for the next word


                        Case Else                                           ;This is a middle word in the search text, so do an =
                            If $aTSV[$t][11] = $aSearchText[$t - $iFoundAt + 1] Then
                                ;Leave the [0] coord as-is
                                If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                ContinueLoop                                ;Possible that there is only 1 search word, so need to continue loop so the Start and End don't get triggered
                            Else
                                $i = $iFoundAt
                                ContinueLoop(2)                             ;if we didn't find the last word in the search text, start the search over
                            EndIf

                    EndSelect

                Next

            Next


        Case 2      ;The word/sentence ends with the specified text
            For $i = 1 to UBound($aTSV) - 1                                 ;Search the contents of the OCR text array

                If StringRight($aTSV[$i][11], StringLen($aSearchText[1])) <> $aSearchText[1] Then   ;Ensure the first word is the last part
                    ContinueLoop                                            ;This is not the text we are looking for
                EndIf

                Local $aTmpCoords[4]                                        ;Create array to store the coords until we are sure it's a full match
                Local $iFoundAt = $i                                        ;Save the # we found the first word at, incase this isn't the whole sentence
                Local $iCount = 0                                           ;Used to count the current word in the search text array we are on

                For $t = $i to $i + ($aSearchText[0] - 1)                   ;Looks like this is what we want, verify everything matches.

                    $iCount += 1
                    Select

                        Case $iCount = $aSearchText[0]                      ;This is the last word in the text we are looking for

                            If $iCount = 1 Then                             ;If this is actually the first & last then we need to save the Coords directly

                                If StringRight($aTSV[$i][11], StringLen($aSearchText[1])) = $aSearchText[($t - $iFoundAt) + 1] Then ;This is the first & Last word to find, so ensure it Ends with
                                    $aTmpCoords[0] = $aTSV[$t][6]           ;Save the left value into the Temp Coords array
                                    $aTmpCoords[1] = $aTSV[$t][7]           ;Save the Top value into the Temp Coords array
                                    $aTmpCoords[2] = $aTSV[$t][8]           ;Save the Width value into the Temp Coords array
                                    $aTmpCoords[3] = $aTSV[$t][9]           ;Save the Height value into the Temp Coords array
                                Else
                                    ContinueLoop(2)                         ;not found, so continue looking for full match
                                EndIf

                            Else                                            ;This is the last but not the first, so we need to match exact since nothing should be before or after.

                                If $aTSV[$t][11] = $aSearchText[($t - $iFoundAt) + 1] Then
                                    If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                    $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                    If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                Else
                                    ContinueLoop(2)
                                EndIf

                            EndIf

                            $iFoundCount += 1                               ;This is a full match, so Increase the successful match by 1

                            $aCoords[0] = $aTmpCoords[0]                    ;Save the Temp Coordinates
                            $aCoords[1] = $aTmpCoords[1]
                            $aCoords[2] = $aTmpCoords[2]
                            $aCoords[3] = $aTmpCoords[3]

                            If $iMatch = $iFoundCount Then                  ;See if this is the match we want, defaults to the first match found
                                ;If there are multiple words, need to identify how many pixels to include where the spaces should have been
                                If $aSearchText[0] > 1 Then
                                    $iSpace = $aTSV[$t][8] / StringLen($aTSV[$t][11])   ;Get width of this word, then divide by the character length to get pixels per character
                                    $sTxtOnly = StringStripWS($sTextToFind, 8)
                                    $iSpace = $aCoords[2] / StringLen($sTxtOnly)        ;Divide the total width by the number of characters to get Pixels per character
                                    $aCoords[2] += ($iSpace * ($aSearchText[0] - 1))
                                EndIf

                                ;Convert the coordinates to onscreen coords according to the scale
                                $aCoords[0] = $aCoords[0] / $scale
                                $aCoords[1] = $aCoords[1] / $scale
                                $aCoords[2] = $aCoords[2] / $scale
                                $aCoords[3] = $aCoords[3] / $scale
                                Return $aCoords
                            Else
                                ContinueLoop(2)                             ;We found the full search text, but we don't want this one.
                            EndIf


                        Case $iCount = 1
                            If StringRight($aTSV[$i][11], StringLen($aSearchText[($t - $iFoundAt) + 1])) = $aSearchText[($t - $iFoundAt) + 1] Then
                                $aTmpCoords[0] = $aTSV[$t][6]                   ;Save the left value into the Temp Coords array
                                $aTmpCoords[1] = $aTSV[$t][7]                   ;Save the top value into the Temp Coords array
                                $aTmpCoords[2] = $aTSV[$t][8]                   ;Save the width value into the Temp Coords array
                                $aTmpCoords[3] = $aTSV[$t][9]                   ;Save the height value into the Temp Coords array
                                ContinueLoop                                    ;Look for the next word
                            Else
                                ContinueLoop(2)
                            EndIf


                        Case Else                                               ;This is a middle word in the search text, so do an =
                            If $aTSV[$t][11] = $aSearchText[$t - $iFoundAt + 1] Then
                                ;Leave the [0] coord as-is
                                If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                ContinueLoop                                    ;Possible that there is only 1 search word, so need to continue loop so the Start and End don't get triggered
                            Else
                                ContinueLoop(2)                                 ;if we didn't find the last word in the search text, start the search over
                            EndIf

                    EndSelect

                Next

            Next


        Case 3      ;The word/sentence match exactly with what is specified
            For $i = 1 to UBound($aTSV) - 1                                 ;Search the contents of the OCR text array

                If $aTSV[$i][11] <> $aSearchText[1] Then                    ;Ensure the first word matches
                    ContinueLoop                                            ;This is not the text we are looking for
                EndIf

                Local $aTmpCoords[4]                                        ;Create array to store the coords until we are sure it's a full match
                Local $iFoundAt = $i                                        ;Save the # we found the first word at, incase this isn't the whole sentence
                Local $iCount = 0                                           ;Used to count the current word in the search text array we are on

                For $t = $i to $i + ($aSearchText[0] - 1)                   ;Looks like this is what we want, verify everything matches.

                    $iCount += 1
                    Select

                        Case $iCount = $aSearchText[0]                      ;This is the last word in the text we are looking for

                            If $iCount = 1 Then                             ;If this is actually the first & last then we need to save the Coords directly

                                If $aTSV[$i][11] = $aSearchText[($t - $iFoundAt) + 1] Then  ;This is the first & Last word to find, so ensure it matches exact
                                    $aTmpCoords[0] = $aTSV[$t][6]           ;Save the left value into the Temp Coords array
                                    $aTmpCoords[1] = $aTSV[$t][7]           ;Save the Top value into the Temp Coords array
                                    $aTmpCoords[2] = $aTSV[$t][8]           ;Save the Width value into the Temp Coords array
                                    $aTmpCoords[3] = $aTSV[$t][9]           ;Save the Height value into the Temp Coords array
                                Else
                                    ContinueLoop(2)                         ;not found, so continue looking for full match
                                EndIf

                            Else                                            ;This is the last but not the first, so we need to match exact since nothing should be before or after.

                                If $aTSV[$t][11] = $aSearchText[($t - $iFoundAt) + 1] Then
                                    If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                    $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                    If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                Else
                                    ContinueLoop(2)
                                EndIf

                            EndIf

                            $iFoundCount += 1                               ;This is a full match, so Increase the successful match by 1

                            $aCoords[0] = $aTmpCoords[0]                    ;Save the Temp Coordinates
                            $aCoords[1] = $aTmpCoords[1]
                            $aCoords[2] = $aTmpCoords[2]
                            $aCoords[3] = $aTmpCoords[3]

                            If $iMatch = $iFoundCount Then                  ;See if this is the match we want, defaults to the first match found

                                ;If there are multiple words, need to identify how many pixels to include where the spaces should have been
                                If $aSearchText[0] > 1 Then
                                    $iSpace = $aTSV[$t][8] / StringLen($aTSV[$t][11])   ;Get width of this word, then divide by the character length to get pixels per character
                                    $sTxtOnly = StringStripWS($sTextToFind, 8)
                                    $iSpace = $aCoords[2] / StringLen($sTxtOnly)        ;Divide the total width by the number of characters to get Pixels per character
                                    $aCoords[2] += ($iSpace * ($aSearchText[0] - 1))
                                EndIf

                                ;Convert the coordinates to onscreen coords according to the scale
                                $aCoords[0] = $aCoords[0] / $scale
                                $aCoords[1] = $aCoords[1] / $scale
                                $aCoords[2] = $aCoords[2] / $scale
                                $aCoords[3] = $aCoords[3] / $scale
                                Return $aCoords
                            Else
                                ContinueLoop(2)                             ;We found the full search text, but we don't want this one.
                            EndIf


                        Case $iCount = 1
                            If $aTSV[$i][11] = $aSearchText[($t - $iFoundAt) + 1] Then
                                $aTmpCoords[0] = $aTSV[$t][6]               ;Save the left value into the Temp Coords array
                                $aTmpCoords[1] = $aTSV[$t][7]               ;Save the top value into the Temp Coords array
                                $aTmpCoords[2] = $aTSV[$t][8]               ;Save the width value into the Temp Coords array
                                $aTmpCoords[3] = $aTSV[$t][9]               ;Save the height value into the Temp Coords array
                                ContinueLoop                                ;Look for the next word
                            Else
                                ContinueLoop(2)
                            EndIf


                        Case Else                                           ;This is a middle word in the search text, so do an =
                            If $aTSV[$t][11] = $aSearchText[$t - $iFoundAt + 1] Then
                                ;Leave the [0] coord as-is
                                If $aTmpCoords[1] > $aTSV[$t][7] Then $aTmpCoords[1] = $aTSV[$t][7] ;Use the top most coord avail
                                $aTmpCoords[2] += $aTSV[$t][8]                                      ;Add this words width to what we already have
                                If $aTmpCoords[3] < $aTSV[$t][9] Then $aTmpCoords[3] = $aTSV[$t][9] ;Use the value with the greatest height
                                ContinueLoop                                ;Possible that there is only 1 search word, so need to continue loop so the Start and End don't get triggered
                            Else
                                ContinueLoop(2)                             ;if we didn't find the last word in the search text, start the search over
                            EndIf

                    EndSelect

                Next

            Next

        Case Else
            ConsoleWrite("Invalid $iFindType value" & @CRLF)
            Return SetError(1, 0, $aCoords)

    EndSwitch

    If $iMatch = -1 Then        ;If the $iMatch = -1 then we want the last match found which should now be set to the $aCoords array, so return that
        $aCoords[0] = $aCoords[0] / $scale
        $aCoords[1] = $aCoords[1] / $scale
        $aCoords[2] = $aCoords[2] / $scale
        $aCoords[3] = $aCoords[3] / $scale
        Return $aCoords
    EndIf

    Return SetError(1, 0, $aCoords) ;If we got this far, then text was not found

EndFunc ;_TesseractFindCoords()





; #FUNCTION# ===============================================================================
;
; Name...........:  _TesseractCaptureText()
; Description ...:  Captures text from a control or Window
; Syntax.........:  _TesseractCaptureText($win_title, $win_text = "", $ctrl_id = "", $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $tsv = 0)
; Parameters ....:  $win_title          - The title of the window to capture text from.
;                   $win_text           - Optional: The text of the window to capture text from.
;                   $ctrl_id            - Optional: The ID of the control to capture text from.
;                                           The text of the window will be returned if one isn't provided.
;~ 					$lang               - The language to scan
;                   $scale              - Optional: The scaling factor of the screenshot prior to text recognition.
;                                           Increase this number to improve accuracy.
;                                           The default is 2.
;                   $left_indent        - A number of pixels to indent the capture from the
;                                           left of the control.
;                   $top_indent         - A number of pixels to indent the capture from the
;                                           top of the control.
;                   $right_indent       - A number of pixels to indent the capture from the
;                                           right of the control.
;                   $bottom_indent      - A number of pixels to indent the capture from the
;                                           bottom of the control.
;                   $tsv                - What type of return you want
;                                           0 = Return text in a 1D array
;                                           1 = Returns 2D array showing text and the exact position found within the control
;
; Return values .:  On Success  - Returns an array of text that was captured.  Global Var ($aOCR_IMG_ORI) is the starting coord the OCR image was captured from
;                   On Failure  - Returns an empty array.
; Author ........:  seangriffin - Was origionally _TesseractControlCapture() function
;
; Modified.......:  BigDaddyO   - Included new ability to capture coords using $tsv (requires 3.05+)
;                               - Removed the dropdown and listbox stuff as they should allow their text to be pulled directly without OCR
;                               - Removed the Cleanup option as that wasn't compatible with the new tsv options.
;                               - Removed the scrolling option as it added a lot of complications and could just call this function +1 times to do the same if text not found
;
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
;
;==========================================================================================
Func _TesseractCaptureText($win_title, $win_text = "", $ctrl_id = "", $lang = " -l vie", $LaOCR_IMG_ORI = $aOCR_IMG_ORI, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $tsv = 0, $Debug = 0)

    if Not IsDeclared($aOCR_IMG_ORI) Then Global $aOCR_IMG_ORI
    Local $aArray, $hwnd

    ; if a control ID is specified, then get it's HWND
    if StringCompare($ctrl_id, "") <> 0 Then
        $hwnd = ControlGetHandle($win_title, $win_text, $ctrl_id)
    EndIf

    ; Perform the text recognition
    WinActivate($win_title)
    $capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
    $ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)

    $Capture = CaptureToTIFF($win_title, $win_text, $hwnd, $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)
    If @error Then
        ConsoleWrite("Error Capturing TIFF for OCR (" & $Capture & ")" & @CRLF)
    EndIf
    $LaOCR_IMG_ORI = $Capture
    $aOCR_IMG_ORI = $Capture

    ConsoleWrite("Area that will be scanned for OCR: " & $Capture[0] & "," & $Capture[1] & "," & $Capture[2] & "," & $Capture[3] & @CRLF)

    If $tsv = 1 Then
        $ocr_filename_and_ext = $ocr_filename & ".tsv"
        ShellExecuteWait($tesseract_path & "tesseract.exe", $capture_filename & " " & $ocr_filename & $lang & " tsv" , $tesseract_path, "open", @SW_HIDE)    ;This will return a tab seperated file
    Else
        $ocr_filename_and_ext = $ocr_filename & ".txt"
        ShellExecuteWait($tesseract_path & "tesseract.exe", $capture_filename & " " & $ocr_filename & $lang, $tesseract_path, "open", @SW_HIDE)
    EndIf

    If $tsv = 1 Then
        _FileReadToArray($ocr_filename_and_ext, $aArray, 0, @TAB)   ;Build a 2D array
    Else
        _FileReadToArray($ocr_filename_and_ext, $aArray, 0)         ;This will return each line of text in a 1D array
    EndIf

      FileDelete($ocr_filename & ".*")

    Return $aArray

EndFunc


;Draw the black line over the text we found prior to taking a screenshot
;   Note, if running from ScITE consolewrites and some other things within the script can refresh the screen and delete the redactions
;       Best if you can move ScITE to a different screen than the redaction is running on, or just run as compiled.
Func _Redact($iX, $iY, $iWidth, $iHeight, $iColor)

    Local $hDC = _WinAPI_GetWindowDC(0)                                                     ;DC of entire screen (desktop)
    Local $hPen = _WinAPI_CreatePen($PS_SOLID, $iHeight, $iColor)                           ;Create a solid pen object with the color provided
    Local $oSelect = _WinAPI_SelectObject($hDC, $hPen)                                      ;Select the $hDC and use the $hPen for this line
    _WinAPI_DrawLine($hDC, $iX, $iY + ($iHeight / 2), $iX + $iWidth, $iY + ($iHeight / 2))  ;Draw the line in the middle, Pen size should cover everything

    _WinAPI_DeleteObject($hPen)
    _WinAPI_SelectObject($hDC, $oSelect)
    _WinAPI_ReleaseDC(0, $hDC)

EndFunc   ;==>_WinAPI_DrawRect



; #FUNCTION# ;===============================================================================
;
; Name...........:  CaptureToTIFF()
; Description ...:  Captures an image of the screen, a window or a control, and saves it to a TIFF file.
; Syntax.........:  CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0)
; Parameters ....:  $win_title      - The title of the window to capture an image of.
;                   $win_text       - Optional: The text of the window to capture an image of.
;                   $ctrl_id        - Optional: The ID of the control to capture an image of.
;                                       An image of the window will be returned if one isn't provided.
;                   $sOutImage      - The filename to store the image in.
;                   $scale          - Optional: The scaling factor of the capture.
;                   $left_indent    - A number of pixels to indent the screen capture from the
;                                       left of the window or control.
;                   $top_indent     - A number of pixels to indent the screen capture from the
;                                       top of the window or control.
;                   $right_indent   - A number of pixels to indent the screen capture from the
;                                       right of the window or control.
;                   $bottom_indent  - A number of pixels to indent the screen capture from the
;                                       bottom of the window or control.
; Return values .:  None
; Author ........:  seangriffin
; Modified.......:  BigDaddyO       - Returns the Position of the object we are scanning for text
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:  No
;
; ;==========================================================================================
Func CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0)

    Local $hWnd, $hwnd2, $hDC, $hBMP, $hImage1, $hGraphic, $CLSID, $tParams, $pParams, $tData, $i = 0, $hImage2, $pos[4], $screenpos[4]
    Local $Ext = StringUpper(StringMid($sOutImage, StringInStr($sOutImage, ".", 0, -1) + 1))
    Local $giTIFColorDepth = 24
    Local $giTIFCompression = $GDIP_EVTCOMPRESSIONNONE

    ; If capturing a control
    if StringCompare($ctrl_id, "") <> 0 Then

        $hwnd2 = ControlGetHandle($win_title, $win_text, $ctrl_id)
        $pos = WinGetPos($hwnd2)                                        ;WinGetPos works for controls as well if you pass the handle as the window title

    Else

        ; If capturing a window
        if StringCompare($win_title, "") <> 0 Then

            $hwnd2 = WinGetHandle($win_title, $win_text)
            $pos = WinGetPos($win_title, $win_text)

        Else

            ; If capturing the desktop
            $hwnd2 = ""
            $pos[0] = 0
            $pos[1] = 0
            $pos[2] = @DesktopWidth
            $pos[3] = @DesktopHeight

        EndIf
    EndIf

    If $pos[2] < 1 or $pos[3] < 1 Then Return SetError(1, 0, "No Width or Height found for specified item")

    ; Capture an image of the window / control
    if IsHWnd($hwnd2) Then

        WinActivate($win_title, $win_text)
        $hBitmap2 = _ScreenCapture_CaptureWnd("", $hwnd2, 0, 0, -1, -1, False)
    Else

        $hBitmap2 = _ScreenCapture_Capture("", 0, 0, -1, -1, False)
    EndIf

    _GDIPlus_Startup ()

    ; Convert the image to a bitmap
    $hImage2 = _GDIPlus_BitmapCreateFromHBITMAP ($hBitmap2)

    $hWnd = _WinAPI_GetDesktopWindow()
    $hDC = _WinAPI_GetDC($hWnd)
    $hBMP = _WinAPI_CreateCompatibleBitmap($hDC, ($pos[2] * $scale) - ($right_indent * $scale), ($pos[3] * $scale) - ($bottom_indent * $scale))

    _WinAPI_ReleaseDC($hWnd, $hDC)
    $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP ($hBMP)
    $hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage1)
    _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage2, 0 - ($left_indent * $scale), 0 - ($top_indent * $scale), ($pos[2] * $scale) + $left_indent, ($pos[3] * $scale) + $top_indent)
    $CLSID = _GDIPlus_EncodersGetCLSID($Ext)

    ; Set TIFF parameters
    $tParams = _GDIPlus_ParamInit(2)
    $tData = DllStructCreate("int ColorDepth;int Compression")
    DllStructSetData($tData, "ColorDepth", $giTIFColorDepth)
    DllStructSetData($tData, "Compression", $giTIFCompression)
    _GDIPlus_ParamAdd($tParams, $GDIP_EPGCOLORDEPTH, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "ColorDepth"))
    _GDIPlus_ParamAdd($tParams, $GDIP_EPGCOMPRESSION, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "Compression"))
    If IsDllStruct($tParams) Then $pParams = DllStructGetPtr($tParams)

    ; Save TIFF and cleanup
    _GDIPlus_ImageSaveToFileEx($hImage1, $sOutImage, $CLSID, $pParams)
    _GDIPlus_ImageDispose($hImage1)
    _GDIPlus_ImageDispose($hImage2)
    _GDIPlus_GraphicsDispose ($hGraphic)
    _WinAPI_DeleteObject($hBMP)
    _GDIPlus_Shutdown()

    $pos[0] += $left_indent
    $pos[1] += $top_indent
    $pos[2] -= $left_indent - $right_indent ;Subtract the left and right indent from the overall width
    $pos[3] -= $top_indent - $bottom_indent ;Subtract the top and bottom indent from the overall height

    Return $pos                             ;Return the expected size of the control/window that was captured

EndFunc
;~ Func SaveTiffImage()
;~     _GDIPlus_Startup()
;~     Local Const $iW = @DesktopWidth , $iH = @DesktopHeight
;~     Local $hHBmp = _ScreenCapture_Capture("", 80, 195, 120, 208) ;create a GDI bitmap by capturing 1/16 of desktop
;~     Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ;convert GDI bitmap to GDI+ bitmap
;~     _WinAPI_DeleteObject($hHBmp) ;release GDI bitmap resource because not needed anymore

;~     Local $hBitmap_Scaled = _GDIPlus_ImageScale($hBitmap, $iScale, $iScale, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR) ;scale image by 275% (magnify)

;~     ; Save resultant image
;~     _GDIPlus_ImageSaveToFile($hBitmap_Scaled, $TIF_FILENAME)

;~     ;cleanup resources
;~      _GDIPlus_BitmapDispose($hBitmap)
;~     _GDIPlus_BitmapDispose($hBitmap_Scaled)
;~     _GDIPlus_Shutdown()
;~ EndFunc   ;==>Example

;~ func AnalyzeImage()
;~     Local $hTimer = TimerInit() ; Begin the timer and store the handle in a variable.

;~     shellexecutewait($TESS_EXE, $TESS_PARAMS, $TWorkDir)
;~     Local $fDiff = TimerDiff($hTimer) ; Find the difference in time from the previous call of TimerInit. The variable we stored the TimerInit handlem is passed as the "handle" to TimerDiff.
;~     consolewrite( ($fDiff/1000) &  "seconds passed")
;~ EndFunc
