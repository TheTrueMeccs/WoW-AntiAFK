#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=
$GUI = GUICreate("WoW AntiAFK", 482, 225, -1, -1)
$antiAfkButton = GUICtrlCreateButton("Run AntiAFK", 280, 88, 147, 49)
$activeWindowNameLabel = GUICtrlCreateLabel("Name of the window to switch to", 24, 144, 189, 17)
$wowInactiveCheckbox = GUICtrlCreateCheckbox("Make WoW inactive after moving", 8, 120, 185, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$windowNameInput = GUICtrlCreateInput("WoW AntiAFK", 24, 160, 193, 21)
$programActiveLabel = GUICtrlCreateLabel("AntiAFK is turned off", 304, 144, 120, 14)
$noteLabel = GUICtrlCreateLabel("Tip: To save energy, set WoW background FPS to minimum and make WoW inactive after moving", 8, 200, 470, 17)
$maximumWaitTimeInput = GUICtrlCreateInput("600", 160, 88, 49, 21)
$minimumWaitTimeInput = GUICtrlCreateInput("300", 160, 64, 49, 21)
$maximumWaitTimeLabel = GUICtrlCreateLabel("Maximum wait time in seconds", 8, 88, 146, 17)
$minimumWaitTimeLabel = GUICtrlCreateLabel("Minimum wait time in seconds", 8, 64, 143, 17)
$introLabel1 = GUICtrlCreateLabel("This bot will activate the WoW window and move the character randomly. Then it will wait random", 8, 16, 465, 17)
$introLabel2 = GUICtrlCreateLabel("time between the specified values below. It can also switch to a specified window after moving.", 16, 32, 452, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Opt("GUIOnEventMode", 1)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlSetOnEvent($antiAfkButton, "_Switch_Anti_AFK")
GUICtrlSetOnEvent($wowInactiveCheckbox, "_Switch_Specific_Window_Options")

Global $antiAfkOn = False
Global $activeWoWEnabled = GUICtrlRead($wowInactiveCheckbox)

Global $GREEN_COLOR = 0x32CD32
Global $RED_COLOR = 0xFF0000
Global $WOW_WINDOW_NAME = "World of Warcraft"
Global $MOVEMENT_KEYS[4] = ["a", "d", "w", "s"]

While 1
	Sleep(10)

	If ($antiAfkOn) Then
		Sleep(1000)
		_Run_Anti_AFK()
	EndIf
WEnd


Func _Switch_Specific_Window_Options()
	If (GUICtrlRead($wowInactiveCheckbox) = $GUI_CHECKED) Then
		GUICtrlSetState($activeWindowNameLabel, $GUI_ENABLE)
		GUICtrlSetState($windowNameInput, $GUI_ENABLE)
	Else
		GUICtrlSetState($activeWindowNameLabel, $GUI_DISABLE)
		GUICtrlSetState($windowNameInput, $GUI_DISABLE)
	EndIf
EndFunc ;==> _Enable_Specific_Window_Options


Func _Switch_Anti_AFK()
	$antiAfkOn = Not $antiAfkOn

	if (Not WinExists($WOW_WINDOW_NAME)) Then
		MsgBox(0x0, "Error", "Make sure WoW is turned on")
		Return
	EndIf

	if ($antiAfkOn) Then
		GUICtrlSetColor($programActiveLabel, $GREEN_COLOR)
		GUICtrlSetData($programActiveLabel, "AntiAFK is turned on")
		GUICtrlSetData($antiAfkButton, "Stop Anti AFK")
	Else
		GUICtrlSetColor($programActiveLabel, $RED_COLOR)
		GUICtrlSetData($programActiveLabel, "AntiAFK is turned off")
		GUICtrlSetData($antiAfkButton, "Run Anti AFK")
	EndIF
EndFunc ;==>__Switch_Anti_AFK


Func _Run_Anti_AFK()
	WinActivate($WOW_WINDOW_NAME)
	$randomKey = $MOVEMENT_KEYS[Random(0, 3)]
	Send("{" & $randomKey & " down}")
	Sleep(Random(50, 180))
	Send("{" & $randomKey & " up}")

	If ($activeWoWEnabled = $GUI_CHECKED) Then
		WinActivate(GUICtrlRead($windowNameInput))
	EndIf

	$randomval = Random(GUICtrlRead($minimumWaitTimeInput) * 1000, GUICtrlRead($maximumWaitTimeInput) * 1000)
	Sleep($randomval)
EndFunc ;==>_Run_Anti_AFK


Func _Exit()
	Exit
EndFunc   ;==>_Exit
