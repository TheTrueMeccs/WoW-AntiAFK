#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=WoWAnitAFK-0.3.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ###
$GUI = GUICreate("WoW AntiAFK", 503, 237, -1, -1)
$antiAfkButton = GUICtrlCreateButton("Run AntiAFK", 320, 72, 147, 49)
$activeWindowNameLabel = GUICtrlCreateLabel("Name of the window to switch to", 24, 168, 189, 17)
$wowInactiveCheckbox = GUICtrlCreateCheckbox("Make WoW inactive after moving", 8, 144, 185, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$windowNameInput = GUICtrlCreateInput("WoW AntiAFK", 24, 184, 193, 21)
$programActiveLabel = GUICtrlCreateLabel("Anti AFK is turned off", 344, 128, 120, 14)
GUICtrlSetColor(-1, 0xFF0000)
$noteLabel = GUICtrlCreateLabel("Tip: To save energy, set WoW background FPS to minimum and make WoW inactive after moving", 16, 216, 470, 17)
$maximumWaitTimeInput = GUICtrlCreateInput("600", 160, 80, 49, 21)
GUICtrlSetLimit(-1, 4)
$minimumWaitTimeInput = GUICtrlCreateInput("300", 160, 56, 49, 21)
GUICtrlSetLimit(-1, 4)
$maximumWaitTimeLabel = GUICtrlCreateLabel("Maximum wait time in seconds", 8, 80, 146, 17)
$minimumWaitTimeLabel = GUICtrlCreateLabel("Minimum wait time in seconds", 8, 56, 143, 17)
$introLabel1 = GUICtrlCreateLabel("This bot will activate the WoW window and move the character randomly. Then it will wait random", 16, 8, 465, 17)
$introLabel2 = GUICtrlCreateLabel("time between the specified values below. It can also switch to a specified window after moving.", 24, 24, 452, 17)
$timeUntilNextMoveLabel = GUICtrlCreateLabel("9999 seconds until next move", 320, 160, 145, 17, $SS_CENTER)
GUICtrlSetState(-1, $GUI_HIDE)
$enterCheckbox = GUICtrlCreateCheckbox("Hit ENTER before moving, in case you logged out", 8, 105, 265, 17)
$unbindingEnterLabel = GUICtrlCreateLabel("Warning: You need to unbind ENTER in WoW", 24, 123, 265, 17)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Opt("GUIOnEventMode", 1)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlSetOnEvent($antiAfkButton, "_Switch_Anti_AFK")
GUICtrlSetOnEvent($wowInactiveCheckbox, "_Switch_Specific_Window_Options")
GUICtrlSetOnEvent($enterCheckbox, "_Switch_Hitting_Enter")

Global $antiAfkOn = False
Global $activeWindowEnabled = GUICtrlRead($wowInactiveCheckbox)
Global $hitEnterEnabled = GUICtrlRead($enterCheckbox)
Global $timeUntilNextMove = 0
Global $prevClampedTimeElapsed = 0

Global $GREEN_COLOR = 0x32CD32
Global $RED_COLOR = 0xFF0000
Global $WOW_WINDOW_NAME = "World of Warcraft"
Global $MOVEMENT_KEYS[4] = ["a", "d", "w", "s"]


While 1
	Sleep(10)

	If ($antiAfkOn) Then
		_Run_Anti_AFK()
	EndIf
WEnd


Func _Switch_Specific_Window_Options()
	$activeWindowEnabled = GUICtrlRead($wowInactiveCheckbox)

	If ($activeWindowEnabled = $GUI_CHECKED) Then
		GUICtrlSetState($activeWindowNameLabel, $GUI_SHOW)
		GUICtrlSetState($windowNameInput, $GUI_SHOW)
	Else
		GUICtrlSetState($activeWindowNameLabel, $GUI_HIDE)
		GUICtrlSetState($windowNameInput, $GUI_HIDE)
	EndIf
EndFunc ;==> _Enable_Specific_Window_Options


Func _Switch_Hitting_Enter()
	$hitEnterEnabled = GUICtrlRead($enterCheckbox)

	If ($hitEnterEnabled == $GUI_CHECKED) Then
		GUICtrlSetState($unbindingEnterLabel, $GUI_SHOW)
	Else
		GUICtrlSetState($unbindingEnterLabel, $GUI_HIDE)
	EndIf
EndFunc ;==> _Switch_Hitting_Enter


Func _Switch_Anti_AFK()
	if (Not WinExists($WOW_WINDOW_NAME)) Then
		MsgBox(0x0, "Error", "Make sure WoW is turned on")
		Return
	EndIf

	$antiAfkOn = Not $antiAfkOn

	if ($antiAfkOn) Then
		GUICtrlSetColor($programActiveLabel, $GREEN_COLOR)
		GUICtrlSetData($programActiveLabel, "AntiAFK is turned on")
		GUICtrlSetData($antiAfkButton, "Stop Anti AFK")
		GUICtrlSetState($timeUntilNextMoveLabel, $GUI_SHOW)
	Else
		GUICtrlSetColor($programActiveLabel, $RED_COLOR)
		GUICtrlSetData($programActiveLabel, "AntiAFK is turned off")
		GUICtrlSetData($antiAfkButton, "Run Anti AFK")
		GUICtrlSetState($timeUntilNextMoveLabel, $GUI_HIDE)
	EndIF
EndFunc ;==>__Switch_Anti_AFK


Func _Run_Anti_AFK()
	$randomWaitTime = Random(GUICtrlRead($minimumWaitTimeInput) * 100, GUICtrlRead($maximumWaitTimeInput) * 100)
	GUICtrlSetData($timeUntilNextMoveLabel, Number(($randomWaitTime) / 100, 1) & " seconds until next move")

	If (_Wait_For_Next_Move($randomWaitTime) = -1) Then
		Return
	EndIf

	WinActivate($WOW_WINDOW_NAME)

	If ($hitEnterEnabled == $GUI_CHECKED) Then
		Send("{Enter}")
	EndIf

	$randomKey = $MOVEMENT_KEYS[Random(0, 3)]
	Send("{" & $randomKey & " down}")
	Sleep(Random(50, 180))
	Send("{" & $randomKey & " up}")

	If ($activeWindowEnabled = $GUI_CHECKED) Then
		WinActivate(GUICtrlRead($windowNameInput))
	EndIf
EndFunc ;==>_Run_Anti_AFK


Func _Wait_For_Next_Move($randomWaitTime)
	For $i = 0 To $randomWaitTime Step 1.6666
		If (Not $antiAfkOn) Then
			Return -1
		EndIf

		$clampedTimeElapsed = $i - Mod($i, 100)

		; Necessary to stop timer text from flickering
		If ($clampedTimeElapsed <> $prevClampedTimeElapsed) Then
			GUICtrlSetData($timeUntilNextMoveLabel, Number(($randomWaitTime - $i) / 100, 1) & " seconds until next move")
		EndIf

		$prevClampedTimeElapsed = $clampedTimeElapsed

		Sleep(10)
	Next
EndFunc ;==> _Wait_For_Next_Move


Func _Exit()
	Exit
EndFunc ;==>_Exit
