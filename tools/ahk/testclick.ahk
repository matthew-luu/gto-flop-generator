#Requires AutoHotkey v2.0
^!s::ExitApp

SendMode("Input")
SetWorkingDir(A_ScriptDir)

CoordMode("Mouse", "Client")
SetDefaultMouseSpeed 0

boardEditorX := 93
boardEditorY := 396

gtoWin := WinExist("ahk_exe GTO.exe")
if !gtoWin {
    MsgBox "GTO window not found! Make sure it is running."
    ExitApp
}

WinRestore(gtoWin)
WinActivate(gtoWin)
WinWaitActive(gtoWin, "", 3)

MsgBox "About to move mouse + click (client coords)."
MouseMove boardEditorX, boardEditorY, 0
Sleep 150
Click
MsgBox "Clicked. Did Board Editor open?"
