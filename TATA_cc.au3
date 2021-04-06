#include "wd_core.au3"
#include "wd_helper.au3"
#include <Array.au3>
#include "HandleImgSearch.au3"
#Include <GDIPlus.au3>
#include "FindImagePosition.au3"
 #include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Date.au3>
#include <ScreenCapture.au3>
$_WD_DEBUG = $_WD_DEBUG_None ;~ set không in lằng nhằng trong console
Global $tesseract_path = "C:\Program Files (x86)\Tesseract-OCR\"
Global $tesseract_temp_path = @TempDir & "\"
Global $aOCR_IMG_ORI, $j
Global $dapAn[4] = ["A", "B", "C", "D"]
Global $dt_wait1 = 0, $dt_wait2=0, $dt_wait=0
Global $hands, $sdesiredcapabilities, $sSession,$aElements
Global $selement,$selement2, $script, $str1, $str2, $str3, $str4, $str5, $str6, $slangnghe, $dahoc = 0
Local $Result, $pRand, $tRand, $tempx, $tempy, $Result2, $tentab
Global $value, $link = "https://tataenglish.vn", $sText
$str1 = StringSplit("username", "")
$str2 = StringSplit("password", "")
$pRand = Random(-5, 5, 1)
$hTimer = TimerInit()
Opt("MouseClickDownDelay", 20)
Opt("SendKeyDownDelay",20)

SetupChrome()
_WD_Startup()
If @error <> $_WD_ERROR_Success Then
	Exit -1
EndIf
$sSession = _WD_CreateSession($sDesiredCapabilities)
Sleep(1000)
_WD_Navigate($sSession, $link)
_WD_LoadWait($sSession)
While 1
	Global $sAlarm = StringSplit(_NowTime(4),":")
	If $sAlarm[1] < 5 Or $sAlarm[2] < 5 Then
		Sleep(10000)
	Else
		ExitLoop

	EndIf
WEnd
;~ 	Nhap ten dang nhap
$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//input[@name='username']")
$script = "document.getElementsByName('username')[0].focus();"
_wd_executescript($sSession, $script)
For $i = 1 To $str1[0]
	Sleep(5 + Random(-5, 5, 1))
	_wd_elementaction($sSession, $selement, "value", $str1[$i])
Next
;~ 	Nhap mat khau
Sleep(20 + Random(-5, 20, 1))
_wd_elementaction($sSession, $selement, "value", @TAB)
$selement = _wd_findelement($sSession, $_wd_locator_byxpath, "//input[@name='password']")
For $i = 1 To $str2[0]
	Sleep(5 + Random(-5, 5, 1))
	_wd_elementaction($sSession, $selement, "value", $str2[$i])
Next
;~ 	Bam dang nhap
Sleep(50 + Random(-5, 20, 1))
$script = "document.getElementsByClassName('btn')[0].focus();  document.getElementsByClassName('btn')[0].click();"

_wd_executescript($sSession, $script)
Sleep(1000 + Random(-50, 200, 1))
			Local $hFireFoxWin=0,$aWinList=WinList("[REGEXPCLASS:Chrome(UI)?_WidgetWin_1]")
			For $i=1 To $aWinList[0][0]
				If BitAND(_WinAPI_GetWindowLong($aWinList[$i][1],$GWL_STYLE),$WS_POPUP)=0 Then
				$hFireFoxWin=$aWinList[$i][1]
				ExitLoop
				EndIf
			Next
Local $WindowHandle = ControlGetHandle($hFireFoxWin,"","[CLASS:Intermediate D3D Window; INSTANCE:1]")
;~ 	Chon bai dau tien chua hoan thanh de lam
_WD_WaitElement($sSession, $_wd_locator_byxpath, "//div[@class='day']")
	$script = "var i = 0;" & _
              "var x = document.getElementsByClassName('info');" & _
              "for(i = 0; i<x.length;i++){" & _
              "if( x[i].lastElementChild.firstElementChild.getAttribute('class') != 'circle-percent-100  circle-18' ) {x[i].parentElement.parentElement.click(); break;}" & _
              "}"
_wd_executescript($sSession, $script)
Sleep(1000 + Random(-50, 200, 1))
;~  $script = "if(document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.parentElement.parentElement.childElementCount == 3) { " & _
;~ 		   "document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.parentElement.parentElement.children[1].click(); " & _
;~ 		   "document.getElementsByClassName('fas fa-circle danger')[0].parentElement.parentElement.children[0].firstElementChild.click();} " & _
;~            "else { document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.click();} "

;~ 	Lam lai tu ai 1

$script = "document.getElementsByClassName('fleft exerciseName')[0].firstElementChild.click();"
_wd_executescript($sSession, $script)
_WD_LoadWait($sSession)
If _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='ePlay']/a/button/span[@class='sp']/i[@class='fas fa-reply']") <> "" Then
$script = "document.getElementsByClassName('c-btn c-btn-info c-btn-medium')[0].click()"
_wd_executescript($sSession, $script)
EndIf
_WD_LoadWait($sSession)


;~ 	Hope Luck
_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
$script = "document.getElementById('playButton').click();"
_wd_executescript($sSession, $script)


;~ 	Bat dau lam bai
;~ 	cho trang load moi lan lam lai
While 1
	Sleep(1000)
	;~ 	Neu da lam xong bai roi thi chon bai khac

	If _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='dayAlert']/p") <> "" Then
		$dahoc = 0
		$script = "document.getElementById('btnDayYes').click();"
		_WD_ExecuteScript($sSession, $script)
		_WD_LoadWait($sSession)
		;~ 	Chon bai dau tien chua hoan thanh de lam
		_WD_WaitElement($sSession, $_wd_locator_byxpath, "//div[@class='day']")
		$script = "var i = 0;" & _
              "var x = document.getElementsByClassName('info');" & _
              "for(i = 0; i<x.length;i++){" & _
              "if( x[i].lastElementChild.firstElementChild.getAttribute('class') != 'circle-percent-100  circle-18' ) {x[i].parentElement.parentElement.click(); break;}" & _
              "}"
		_wd_executescript($sSession, $script)
		Sleep(1000 + Random(-50, 200, 1))
;~ 		$script = "if(document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.parentElement.parentElement.childElementCount == 3) { " & _
;~ 		   "document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.parentElement.parentElement.children[1].click(); " & _
;~ 		   "document.getElementsByClassName('fas fa-circle danger')[0].parentElement.parentElement.children[0].firstElementChild.click();} " & _
;~            "else { document.getElementsByClassName('fas fa-play-circle info')[0].parentElement.click();} "
;~ 	Lam lai tu ai 1

$script = "document.getElementsByClassName('fleft exerciseName')[0].firstElementChild.click();"
_wd_executescript($sSession, $script)
_WD_LoadWait($sSession)
If _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='ePlay']/a/button/span[@class='sp']/i[@class='fas fa-reply']") <> "" Then
$script = "document.getElementsByClassName('c-btn c-btn-info c-btn-medium')[0].click()"
_wd_executescript($sSession, $script)
EndIf
_WD_LoadWait($sSession)


		$script = "document.getElementsByClassName('fleft exerciseName')[0].firstElementChild.click();"
	_wd_executescript($sSession, $script)
	_WD_LoadWait($sSession)
	_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
	$script = "document.getElementById('playButton').click();"
	_wd_executescript($sSession, $script)

	EndIf
;~ 	Neu tim duoc nut OK
	$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//button[@id='nextButton']")
;~ 	Truong hop dien tu
	If $selement <> "" And _WD_ElementAction($sSession, $sElement, "displayed", "") Then
		$aElements = _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='row matching-game']","",True)
	If $aElements <> "" Then
		ConsoleWrite("ft")
		For $i = 0 To UBound($aElements-1)
			$script = "var x =document.getElementsByClassName('matching mb');for(var i = 0; i<x.length;i++){" & _
						"if(x[i].parentElement.parentElement.parentElement.parentElement.getAttribute('class') != 'qBox hide')" & _
						"document.getElementById(x[i].id.replace('mb','ma')).click();x[i].click();}"
			_wd_executescript($sSession, $script)
		Sleep(100)
		$script = "document.getElementById('nextButton').click();"
		_wd_executescript($sSession, $script)
		Next
		Sleep(200)
		_WD_LoadWait($sSession)
		$script = "document.getElementById('nextPlayButton').click();"
		_wd_executescript($sSession, $script)
		Sleep(200)
		_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
		$script = "document.getElementById('playButton').click();"
		_wd_executescript($sSession, $script)
	ElseIf _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='scrollSubtitle']")[0] <> "" Then
		While _WD_FindElement($sSession, $_wd_locator_byxpath, "//button[@class='c-btn c-btn-success c-btn-big']") == ""
		_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='nextButton']/span/i[@class='fas fa-forward']")
		Sleep(50)
		 $script = "document.getElementById('nextButton').click();"
		 _wd_executescript($sSession, $script)
		WEnd
		Sleep(100)
		$script = "document.getElementById('nextPlayButton').click();"
		 _wd_executescript($sSession, $script)
		 _WD_LoadWait($sSession)
		 $script = "document.getElementById('playButton').click();"
_wd_executescript($sSession, $script)
;~ 	thuong la nghe cau
	ElseIf _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='qText']/span[@class='danger']") <> "" Then
		$script = "x = document.getElementsByClassName('aInput');" & _
							  "document.getElementsByClassName('center pb10')[0].innerText = ''; " & _
							  "for(var i = 0; i < x.length-1; i++){" & _
                              "document.getElementsByClassName('center pb10')[0].innerText += x[i].id.replace('aI','i')+ ':';  }" & _
                              "document.getElementsByClassName('center pb10')[0].innerText += x[i].id.replace('aI','i'); "
					_wd_executescript($sSession, $script)
					Sleep(500)
					$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//p[@class='center pb10']")
					$sText = StringSplit(_WD_ElementAction($sSession, $sElement, 'text'), ":")
					ConsoleWrite($sText[0])
					For $j = 1  To $sText[0]
						ConsoleWrite("lap lan " & $j & " " & $sText[$j] & @CRLF)
						While _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='circleDuration hide']") <> ""
							$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//input[@id='" & $sText[$j] & "']")
							For $i = 1 To 3
								_WD_ElementAction($sSession, $sElement, 'value', "000")
								$script = "document.getElementById('nextButton').click();"
								_wd_executescript($sSession, $script)
							Next
							_WD_WaitElement($sSession, $_wd_locator_byxpath, "//div[@id='" & StringReplace($sText[$j],"input","aHint") & "']/span")
							$selement2 =_WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='" & StringReplace($sText[$j],"input","aHint") & "']/span[@class='warning']")
							_WD_ElementAction($sSession, $sElement, 'value', _WD_ElementAction($sSession, $selement2, 'text'))
							$script = "document.getElementById('nextButton').click();"
							_wd_executescript($sSession, $script)
						WEnd
						$script = "document.getElementById('circleNext').click();"
						Sleep(100)
						_WD_WaitElement($sSession, $_wd_locator_byxpath, '//i[@class="fas fa-forward font26"]')
						Sleep(100)
						_WD_WaitElement($sSession, $_wd_locator_byxpath, '//i[@class="fas fa-forward font26"]')
						_WD_ExecuteScript($sSession, $script)
						ConsoleWrite($script)
					Next
					Sleep(500)
					$script = "document.getElementById('nextPlayButton').click();"
					_WD_ExecuteScript($sSession, $script)
				_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
				Sleep(500)
				$script = "document.getElementById('playButton').click();"
				_wd_executescript($sSession, $script)
				_WD_LoadWait($sSession)

	Else
		If $dahoc == 0 Then
;~ 			copy word
			WinActivate("TATA - Word")
			Send("{CTRLDOWN}z{CTRLUP}")
			Send("{CTRLDOWN}z{CTRLUP}")
			Send("{CTRLDOWN}z{CTRLUP}")
			Send("{CTRLDOWN}z{CTRLUP}")
			Send("{CTRLDOWN}a{CTRLUP}")
			Sleep(100)
			Send("{CTRLDOWN}c{CTRLUP}")
			Sleep(100)
			If $hFireFoxWin Then WinActivate($hFireFoxWin)
			$script = ClipGet()
			_wd_executescript($sSession, $script)
			Sleep(500)
			$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//p[@class='center pb10']")
            $sText = StringSplit(_WD_ElementAction($sSession, $sElement, 'text'), ":")
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

			Sleep(100)
			Send("{ESC}")
			Send("{CTRLDOWN}a{CTRLUP}")
			Send("{CTRLDOWN}c{CTRLUP}")
			WinActivate($hFireFoxWin)
			$dahoc = 1
		EndIf
		$script = ClipGet()
		_wd_executescript($sSession, $script)
		$script = "if((document.getElementsByClassName('button-answer').length < 1 || window.getComputedStyle(document.getElementsByClassName('button-answer')[0].parentElement.parentElement).display == 'none')" & _
		          " && window.getComputedStyle(document.getElementById('nextPlayButton')).display == 'none'){document.getElementById('nextButton').click();}" & _
				  "else{document.getElementById('nextPlayButton').click();document.getElementsByClassName('button-answer')[" & 1 & "].click();}"
		While _WD_ElementAction($sSession, $sElement, "displayed", "")
			_wd_executescript($sSession, $script)
			ConsoleWrite(" loop1 ")
		WEnd
		_WD_LoadWait($sSession)
		$script = "document.getElementById('nextPlayButton').click();"
		_wd_executescript($sSession, $script)
		$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//button[@class='button-answer']")
		If $selement <> "" And _WD_ElementAction($sSession, $sElement, "displayed", "") Then
		$script = "document.getElementsByClassName('button-answer')[" & Random(0,2) & "].click();"
		_wd_executescript($sSession, $script)
		EndIf
		_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
		$script = "document.getElementById('playButton').click();"
		_wd_executescript($sSession, $script)
		_WD_LoadWait($sSession)
		EndIf
;~ 		Da hoc xong
	Else
;~ 		truong hop nghe chu
		$script = "document.getElementById('playButton').click();"
		_wd_executescript($sSession, $script)
		_WD_LoadWait($sSession)
		$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='circleDuration']")
		If $selement <> "" And _WD_ElementAction($sSession, $sElement, "displayed", "") Then
			ConsoleWrite(" nghe chu ")
			$script = "document.getElementById('circleNext').click();"
			While _WD_ElementAction($sSession, $sElement, "displayed", "")
			_WD_WaitElement($sSession, $_wd_locator_byxpath, "//i[@class='fas fa-forward font26']")
			_wd_executescript($sSession, $script)
			ConsoleWrite(" loop2 ")
			Sleep(1000)
			WEnd
			_WD_LoadWait($sSession)
			$script = "document.getElementById('nextPlayButton').click();"
			_wd_executescript($sSession, $script)
			_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
			$script = "document.getElementById('playButton').click();"
			_wd_executescript($sSession, $script)
			_WD_LoadWait($sSession)
;~ 			Truong hop khac
		Else
			ConsoleWrite(" th khac ")
;~ 			Truong hop noi o chu

			$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='mapping-container qBox']")
			If $selement <> "" And _WD_ElementAction($sSession, $sElement, "displayed", "") Then
				_WD_ExecuteScript($sSession, "location.reload();")
							_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
			$script = "document.getElementById('playButton').click();"
			_wd_executescript($sSession, $script)
			_WD_LoadWait($sSession)
				$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//button[@class='c-btn c-btn-success c-btn-big']")
				If _WD_FindElement($sSession, $_wd_locator_byxpath, "//button[@class='c-btn c-btn-success c-btn-big']") == "" Then
				$script = ClipGet()
				Sleep(100)
				_wd_executescript($sSession, $script)
				ConsoleWrite(" loop3 ")
				EndIf
				Sleep(500)
				$script = "document.getElementById('nextPlayButton').click();"
				_wd_executescript($sSession, $script)
				_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
				$script = "document.getElementById('playButton').click();"
				_wd_executescript($sSession, $script)
				_WD_LoadWait($sSession)
;~ 			Truong hop chon dap an
			ElseIf _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='qText']/p") <> "" Then
			ConsoleWrite("gfg")
			Sleep(200)
			$aElements = _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='qBox']","",True)
			If _WD_ElementAction($sSession, $aElements[0],'attribute', 'suggestion') <> "4" Then
				Local $mang[UBound($aElements)+3]
				For $i = 1  To (UBound($aElements)+1)
					$mang[$i] = 3
				Next

				For $i = 1  To 2
					$script = "var x =document.getElementsByClassName('option');" & _
                              "var t = x[0].className.includes('hide') ? 1 : 0;for(var i = t; i<x.length;i++){" & _
							  "if(x[i].getAttribute('choose') == '"& $dapAn[$i-1] &"') x[i].click();}"
					_wd_executescript($sSession, $script)
					Sleep(1000)
					$script = "document.getElementById('nextButton').click();"
					_wd_executescript($sSession, $script)
					$script = "var x =document.getElementsByClassName('option');document.getElementsByClassName('p10')[0].innerText = '';" & _
							  "var t = x[0].className.includes('hide') ? 1 : 0;for(var i = t; i<x.length;i++){ if(x[i].classList[2] == 'bg-success')" & _
							  "document.getElementsByClassName('center p10')[0].innerText += ((i-t+1-((i+1-t)%3))/3+1).toString()+ ':' + ((i+1-t)%3).toString() + ':' ;}" & _
							  "document.getElementsByClassName('center p10')[0].innerText= document.getElementsByClassName('center p10')[0].innerText.substr(0,document.getElementsByClassName('center p10')[0].innerText.length - 1);"
					_wd_executescript($sSession, $script)
					Sleep(100)
					$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//p[@class='center p10']")
					$sText = StringSplit(_WD_ElementAction($sSession, $sElement, 'text'), ":")
					ConsoleWrite(" " & _ArrayToString($sText, Default, Default, Default, "|", 0, 0) & " ")
					For $j = 1  To $sText[0] Step 2
						$mang[$sText[$j]] = $sText[$j+1]
					Next
					Sleep(500)
					$script = "document.getElementById('nextPlayButton').click();"
					_wd_executescript($sSession, $script)
					Sleep(500)
					$script = "document.getElementById('playButton').click();"
					_wd_executescript($sSession, $script)
				Next
				Sleep(100)
				For $i = 1  To (UBound($aElements)+1)
					ConsoleWrite((($i-1)*3 + $mang[$i] - 1) & " ")
					$script = "var t = document.getElementsByClassName('option')[0].className.includes('hide') ? 1 : 0;document.getElementsByClassName('option')[" & (($i-1)*3 + $mang[$i] - 1)  & "+t].click();"
					_wd_executescript($sSession, $script)
				Next
					Sleep(500)
			        $script = "document.getElementById('nextButton').click();"
					_wd_executescript($sSession, $script)
					Sleep(500)
					$script = "document.getElementById('nextPlayButton').click();"
					_wd_executescript($sSession, $script)
					Sleep(500)
					$script = "document.getElementById('playButton').click();"
					_wd_executescript($sSession, $script)
					Sleep(500)


			EndIf
;~ 			Truong hop nghe sau
			Else
				ConsoleWrite("nghe sau")
				$selement = _WD_FindElement($sSession, $_wd_locator_byxpath, "//span[@class='danger']")
				If $selement <> "" And _WD_ElementAction($sSession, $sElement, "displayed", "") Then
					$script = "x = document.getElementsByClassName('aInput');" & _
							  "document.getElementsByClassName('center pb10')[0].innerText = ''; " & _
							  "for(var i = 0; i < x.length-1; i++){" & _
                              "document.getElementsByClassName('center pb10')[0].innerText += x[i].id.replace('aI','i')+ ':';  }" & _
                              "document.getElementsByClassName('center pb10')[0].innerText += x[i].id.replace('aI','i'); "
					_wd_executescript($sSession, $script)
					Sleep(500)
					$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//p[@class='center pb10']")
					$sText = StringSplit(_WD_ElementAction($sSession, $sElement, 'text'), ":")
					ConsoleWrite($sText[0])
					For $j = 1  To $sText[0]
						ConsoleWrite("lap lan " & $j & " " & $sText[$j] & @CRLF)
						$sElement =_WD_FindElement($sSession, $_wd_locator_byxpath, "//input[@id='" & $sText[$j] & "']")
						While _WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@class='circleDuration hide']") <> ""
							For $i = 1 To 3
								_WD_ElementAction($sSession, $sElement, 'value', "0")
							Next
							_WD_WaitElement($sSession, $_wd_locator_byxpath, "//div[@id='" & StringReplace($sText[$j],"input","aHint") & "']/span")
							$selement2 =_WD_FindElement($sSession, $_wd_locator_byxpath, "//div[@id='" & StringReplace($sText[$j],"input","aHint") & "']/span")
							_WD_ElementAction($sSession, $sElement, 'value', _WD_ElementAction($sSession, $selement2, 'text'))
						WEnd
						$script = "document.getElementById('circleNext').click();"
						Sleep(100)
						_WD_WaitElement($sSession, $_wd_locator_byxpath, '//div[@class="circleNext"]/i[@class="fas fa-forward font26"]',0,30000)
						_WD_ExecuteScript($sSession, $script)
					Next
					_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@class='c-btn c-btn-success c-btn-big']")
					$script = "document.getElementById('nextPlayButton').click();"
					_WD_ExecuteScript($sSession, $script)
				_WD_WaitElement($sSession, $_wd_locator_byxpath, "//button[@id='playButton']")
				Sleep(200)
				$script = "document.getElementById('playButton').click();"
				_wd_executescript($sSession, $script)
				_WD_LoadWait($sSession)
				EndIf

			EndIf
		EndIf
	EndIf

WEnd
;~ 	-------------------------------------------------------------------

Func SetupChrome()
	_WD_Option("Driver", "chromedriver.exe")
	_WD_Option("Port", 9515)
	_WD_Option("DriverParams", '--log-path="' & @ScriptDir & '\chrome.log"')
	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "args": ["start-maximized"] }}}}'
EndFunc
