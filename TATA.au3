#include <Array.au3>
#include "HandleImgSearch.au3"
#Include <GDIPlus.au3>
#include "FindImagePosition.au3"
 #include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <ScreenCapture.au3>

Global $tesseract_path = "C:\Program Files\Tesseract-OCR\"
Global $tesseract_temp_path = @TempDir & "\"
Global $aOCR_IMG_ORI
Global $dt_wait1 = 0, $dt_wait2=0, $dt_wait=0
Local $Result, $pRand, $tRand, $tempx, $tempy, $hocTu = 0
Global $value
 $pRand = Random(-5, 5, 1)
$hTimer = TimerInit()
Opt("MouseClickDownDelay", 20)
;~ Opt("SendKeyDownDelay",20)
Local $hFireFoxWin=0,$aWinList=WinList("[REGEXPCLASS:Mozilla(UI)?WindowClass]")
For $i=1 To $aWinList[0][0]
    If BitAND(_WinAPI_GetWindowLong($aWinList[$i][1],$GWL_STYLE),$WS_POPUP)=0 Then
        $hFireFoxWin=$aWinList[$i][1]
        ExitLoop
    EndIf
Next
If $hFireFoxWin Then WinActivate($hFireFoxWin)
Sleep(100)
Local $WindowHandle = ControlGetHandle("Firefox Developer Edition","","[CLASS:MozillaWindowClass]")
Global $aPos = ControlGetPos("Firefox Developer Edition","","[CLASS:MozillaWindowClass]")
;~ Local $WindowHandle = ControlGetHandle("Firefox Developer Edition", "", "[CLASS:MozillaWindowClass]")
;~ HotKeySet("{ESC}","MyExit")
;~ Global $aPos = ControlGetPos("Firefox Developer Edition", "", "[CLASS:MozillaWindowClass]")
Func MyExit()
    Exit
EndFunc

;~  Hoc tu
$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
If not @error Then
	WinActivate("TATA - Word")
	Send("{CTRLDOWN}a{CTRLUP}")
	Sleep(100)
	Send("{CTRLDOWN}c{CTRLUP}")
	Sleep(100)
	Local $hFireFoxWin=0,$aWinList=WinList("[REGEXPCLASS:Mozilla(UI)?WindowClass]")
	For $i=1 To $aWinList[0][0]
		If BitAND(_WinAPI_GetWindowLong($aWinList[$i][1],$GWL_STYLE),$WS_POPUP)=0 Then
			$hFireFoxWin=$aWinList[$i][1]
			ExitLoop
		EndIf
	Next
	If $hFireFoxWin Then WinActivate($hFireFoxWin)
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
	$hocTu = 1;
;~ 	Neu javascript bao lai thi copy
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\Alert_OK.bmp", 0, 0, -1, -1, 35, 1)
	If not @error Then
		MouseClick("left",$Result[1][0] , $Result[1][1] - 52)
		MouseClick("left",$Result[1][0] , $Result[1][1] - 52)
		MouseClick("left",$Result[1][0] , $Result[1][1] - 52)
		Sleep(50)
		Send("{CTRLDOWN}c{CTRLUP}")
		Local $sText = StringSplit(ClipGet(),":")
		MouseClick("left",$Result[1][0] + 45 , $Result[1][1] + 10)
		Sleep(50)
	EndIf
	While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(200)
			Else
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		EndIf
	WEnd
	Sleep(1000)
;~ 	 NNeu hoc xong roi sang test moi
    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
;~ 	copy du lieu vao word
	WinActivate("TATA - Word")

	Send("{CTRLDOWN}h{CTRLUP}")
	Sleep(100)
	Send("mang2 = ")
	Send("{ALTDOWN}b{ALTUP}")
	Send("mang2 = [")
	For $i = 1 to $sText[0] Step 2
		Send($sText[$i] & ",")
	Next
	Send("{BS}];//")
	Sleep(50)
	Send("{ALTDOWN}a{ALTUP}")
	Sleep(100)
	Send("{ENTER}{ENTER}")

	Sleep(100)
	Send("dulieu = [")
	Send("{ALTDOWN}b{ALTUP}")
	Send("dulieu = [")
	For $i = 2 to $sText[0] Step 2
		Send('"' & $sText[$i] &'"' & ",")
	Next
	Send("{BS}];//")
	Send("{ALTDOWN}a{ALTUP}")
	Sleep(100)
	Send("{ENTER}{ENTER}")

	Sleep(100)
	Send("dahoc=0")
	Send("{ALTDOWN}b{ALTUP}")
	Send("dahoc=1")
	Send("{ALTDOWN}a{ALTUP}")
	Sleep(100)
	Send("{ENTER}{ENTER}")

	Sleep(500)
	Send("{ESC}")
	Send("{CTRLDOWN}a{CTRLUP}")
	Send("{CTRLDOWN}c{CTRLUP}")

	Local $hFireFoxWin=0,$aWinList=WinList("[REGEXPCLASS:Mozilla(UI)?WindowClass]")
	For $i=1 To $aWinList[0][0]
		If BitAND(_WinAPI_GetWindowLong($aWinList[$i][1],$GWL_STYLE),$WS_POPUP)=0 Then
			$hFireFoxWin=$aWinList[$i][1]
			ExitLoop
		EndIf
	Next
	If $hFireFoxWin Then WinActivate($hFireFoxWin)




EndIf
;~  da hoc xong
While 1
If $hocTu ==1 Then
Sleep(3000)
$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
	If not @error Then
		While 1
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				Else
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		EndIf
		WEnd
		Sleep(1000)
	    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
	    EndIf
	EndIf
;~ 	lan 1
	$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		While 1
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				ExitLoop
			EndIf
		WEnd

	EndIf
	Sleep(4000)
;~ 	v
$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
	If not @error Then
		While 1
			ConsoleWrite("tone 2")
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				Else
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ConsoleWrite("good 2")
			ExitLoop
		EndIf
		EndIf
		WEnd
		While 1
	    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				ExitLoop
			EndIf
		WEnd
	EndIf

;~ 	lan 2
	$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				ConsoleWrite("good 3")
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		While 1
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				ConsoleWrite("exx 3")
				ExitLoop
			EndIf
		WEnd

	EndIf
	Sleep(4000)
;~ 	v
$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
	If not @error Then
		While 1
			ConsoleWrite("tone 4")
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\cut.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				Else
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ConsoleWrite("good 4")
			ExitLoop
		EndIf
		EndIf
		WEnd
		While 1
	    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
				ExitLoop
			EndIf
		WEnd
	EndIf

;~ 	lan 3
	$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
	ConsoleWrite("in 5")
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				ConsoleWrite("good 5")
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			ConsoleWrite("hope 5")
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		Sleep(1000)
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf

	EndIf
	;~ 	lan 4
	$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
	ConsoleWrite("good 6")
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		Sleep(1000)
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf

	EndIf
;~ 	lan 5
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\bthuong.bmp", 0, 0, -1, -1, 35, 1)
	If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 50 + $pRand)
				MouseMove(10,10)
				Sleep(100)
	EndIf
	$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
	ConsoleWrite("good 7")
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$i = 0
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	While @error
	$i = $i + 1
	If $i > 2 Then
			ExitLoop
		EndIf
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\OKbtn" &  $i & ".bmp", 0, 0, -1, -1, 45, 1)
	WEnd
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		Sleep(1000)
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf

	EndIf


;~ 	noi audio
    While 1
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\noi_audio.bmp", 0, 0, -1, -1, 45, 1)
    If not @error Then
	Send("{F12}")
	Sleep(100)
	Send("{CTRLDOWN}{SHIFTDOWN}k{CTRLUP}{SHIFTUP}")
	Sleep(200)
	Send("{CTRLDOWN}v{CTRLUP}")
	Sleep(1500)
	Send("{ENTER}")
	Sleep(500)
	Send("{F12}")
	Sleep(500)
		While 1
		$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\NextS.bmp", 0, 0, -1, -1, 35, 1)
		If not @error Then
			MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
			MouseMove(10,10)
			ExitLoop
		EndIf
		WEnd
		Sleep(1000)
		    $Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\mau_xanh.bmp", 0, 0, -1, -1, 35, 1)
			If not @error Then
				MouseClick("left",$Result[1][0] + 35 + $pRand , $Result[1][1] + 35 + $pRand)
				MouseMove(10,10)
				Sleep(100)
			EndIf
	Else
		ExitLoop
	EndIf
	Sleep(200)
	WEnd
;~ 	lan nay la nghe sau
	$Result = _HandleImgSearch($WindowHandle, @ScriptDir & "\Images\TATA\nghesau.bmp", 0, 0, -1, -1, 45, 1)
	If not @error Then
				MouseClick("left",672 ,267)
				Send("111")
				Sleep(100)
				MouseClick("left",716,322)
				MouseClick("left",716,322)
				Send("{CTRLDOWN}c{CTRLUP}")
				Sleep(100)
				MouseClick("left",672 ,267)
				MouseClick("left",672 ,267)
				Send(ClipGet())
				Sleep(100)
			EndIf
EndIf
WEnd

;~ Func _ConvertTime($x, $y, $width, $height)
;~ Local $hGUI = GUICreate("Example",$width, $height, $x, $y)
;~ _ScreenCapture_CaptureWnd(@ScriptDir & "\Temp\cap.bmp",$hGUI)
;~ Sleep(1000)
;~ ShellExecuteWait($tesseract_path & "tesseract.exe", @ScriptDir & "\Temp\cap.bmp " & @ScriptDir & "\Temp\text", $tesseract_path, "open", @SW_HIDE)
;~ Sleep(2000)
;~ Local $sText = StringTrimRight(FileRead(@ScriptDir & "\Temp\text.txt"),2)
;~ $sText = StringSplit($sText,".")
;~ for $i = 1 to $sText[0]
;~ 	ConsoleWrite($sText[$i] & @CRLF)
;~ Next
;~ Return 0
;~ EndFunc













