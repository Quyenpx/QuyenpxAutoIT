#Region
#AutoIt3Wrapper_Icon= shutdown.ico

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <DateTimeConstants.au3>; form timePicker
#include <Date.au3>

#Region ### START Koda GUI section ### Form=
Global $FormMain = GUICreate("AutoShutdown", 531, 559, -1, -1)
GUISetFont(14, 400, 0, "Segoe UI")
Global $LabelSelect = GUICtrlCreateLabel("Select Option", 40, 24, 117, 29)
Global $ComboSelect = GUICtrlCreateCombo("", 32, 64, 145, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Shutdown|Restart",'Shutdown')
Global $CheckboxForceClose = GUICtrlCreateCheckbox("Force running applications to close", 32, 128, 353, 17)
Global $CheckboxTimeOut = GUICtrlCreateCheckbox("Set the time-out period before shutdown", 32, 168, 433, 33)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $LabelTimeOut = GUICtrlCreateLabel("Time-out", 32, 232, 81, 29)
Global $InputTimeOut = GUICtrlCreateInput("30", 136, 224, 105, 33, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER,$ES_NUMBER))
Global $LabelSecond = GUICtrlCreateLabel("seconds", 264, 224, 81, 29)
Global $ButtonTimePicker = GUICtrlCreateButton("Time Picker", 384, 224, 123, 33)
Global $LabelComment = GUICtrlCreateLabel("Comment", 32, 304, 86, 29)
Global $EditComment = GUICtrlCreateEdit("", 33, 344, 481, 89)
Global $ButtonStart = GUICtrlCreateButton("Start", 33, 456, 227, 25)
Global $ButtonAbort = GUICtrlCreateButton("Abort", 280, 456, 219, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


#Region ### START Koda GUI section ### Form=
Global $FormTimePicker = GUICreate("SelectTime", 225, 141, -1, -1)
GUISetFont(14, 400, 0, "Segoe UI")
Global $DatePicker = GUICtrlCreateDate("", 24, 16, 178, 33, BitOR($DTS_UPDOWN,$DTS_TIMEFORMAT))
Global $sStyle = "yyyy/MM/dd HH:mm:ss"
GUICtrlSendMsg($DatePicker, $DTM_SETFORMATW, 0, $sStyle)



Global $ButtonOK = GUICtrlCreateButton("OK", 24, 88, 179, 25)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg(1) ; bật chế độ nâng cao
	Switch $nMsg[0]
		Case $GUI_EVENT_CLOSE
			If $nMsg[1] == $FormMain Then
				Exit
			EndIf

			If $nMsg[1] == $FormTimePicker Then
				GUISetState(@SW_HIDE,$FormTimePicker)
			EndIf
		Case $CheckboxTimeOut
			;Chỉ khi check box được tích : cho phép nhập
			If GUICtrlRead($CheckboxTimeOut) == $GUI_CHECKED Then
				toggleTimeout(True)
			Else
				toggleTimeout(False)
			EndIf
		Case $ButtonTimePicker
			GUISetState(@SW_SHOW,$FormTimePicker)
		Case $EditComment

		Case $ButtonStart
			;MsgBox(0,0,generateCommand())
			Run(generateCommand(),'',@SW_HIDE)
		Case $ButtonAbort
			Run('shutdown -a','',@SW_HIDE)
			MsgBox(64+262144,'Thông báo','Đã hủy thành công')
		Case $ButtonOK
			Local $datetime = GUICtrlRead($DatePicker)
			Local $seconds = _DateDiff('s',_NowCalc(),$datetime)
			If $seconds <= 0 Then
				MsgBox(16+262144,'Lỗi','Vui lòng chọn một thời gian hợp lệ')
			Else
				GUICtrlSetData($InputTimeOut,$seconds)
				GUISetState(@SW_HIDE,$FormTimePicker)
			EndIf
	EndSwitch
WEnd

Func toggleTimeout($enable)
	Local $value = $enable ? $GUI_ENABLE : $GUI_DISABLE

	GUICtrlSetState($LabelTimeOut,$value)
	GUICtrlSetState($InputTimeOut,$value)
	GUICtrlSetState($LabelSecond,$value)
	GUICtrlSetState($ButtonTimePicker,$value)

	If $value Then
		GUICtrlSetState($InputTimeOut,$value)
	EndIf
EndFunc

Func generateCommand()
	Local $cmd = 'shutdown'
	;Kiểm tra các tùy chọn của người dùng
	;shutdown hay restart
	Local $action = GUICtrlRead($ComboSelect)
	$cmd &= ' ' & ($action == 'Shutdown' ? '-s' :'-r')

	;Đóng các ứng dụng
	If GUICtrlRead($CheckboxForceClose) == $GUI_CHECKED Then
		$cmd &= ' -f'
	EndIf

	;Có đặt thời gian chờ hay không
	If GUICtrlRead($CheckboxTimeOut) == $GUI_CHECKED Then
		Local $timeout = GUICtrlRead($InputTimeOut)
		If Not $timeout Then
			GUICtrlSetData($InputTimeOut,'30')
		EndIf
		$cmd &= ' -t '&$timeout
	EndIf

	; có nhập lời nhắn gì không ?
	Local $comment = GUICtrlRead($EditComment)
	If $comment Then
		$cmd &= ' -c "'& $comment &'"'
	EndIf
	Return $cmd
EndFunc