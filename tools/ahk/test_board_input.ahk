#Requires AutoHotkey v2.0

^!s::ExitApp  ; Ctrl+Alt+S to safely stop the script

SendMode("Input")
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Client")

; ---------- Helpers ----------
ShowStep(text, x := 10, y := 10) {
    ToolTip text, x, y
}

ClearStep() {
    ToolTip
}

; ---------- Card coordinates ----------
cards := Map()

; Hearts
cards["Ah"] := [196,196]
cards["Kh"] := [196,231]
cards["Qh"] := [196,266]
cards["Jh"] := [196,301]
cards["Th"] := [196,336]
cards["9h"] := [196,371]
cards["8h"] := [196,406]
cards["7h"] := [196,441]
cards["6h"] := [196,476]
cards["5h"] := [196,511]
cards["4h"] := [196,546]
cards["3h"] := [196,581]
cards["2h"] := [196,616]

; Clubs
cards["Ac"] := [232,196]
cards["Kc"] := [232,231]
cards["Qc"] := [232,266]
cards["Jc"] := [232,301]
cards["Tc"] := [232,336]
cards["9c"] := [232,371]
cards["8c"] := [232,406]
cards["7c"] := [232,441]
cards["6c"] := [232,476]
cards["5c"] := [232,511]
cards["4c"] := [232,546]
cards["3c"] := [232,581]
cards["2c"] := [232,616]

; Diamonds
cards["Ad"] := [268,196]
cards["Kd"] := [268,231]
cards["Qd"] := [268,266]
cards["Jd"] := [268,301]
cards["Td"] := [268,336]
cards["9d"] := [268,371]
cards["8d"] := [268,406]
cards["7d"] := [268,441]
cards["6d"] := [268,476]
cards["5d"] := [268,511]
cards["4d"] := [268,546]
cards["3d"] := [268,581]
cards["2d"] := [268,616]

; Spades
cards["As"] := [304,196]
cards["Ks"] := [304,231]
cards["Qs"] := [304,266]
cards["Js"] := [304,301]
cards["Ts"] := [304,336]
cards["9s"] := [304,371]
cards["8s"] := [304,406]
cards["7s"] := [304,441]
cards["6s"] := [304,476]
cards["5s"] := [304,511]
cards["4s"] := [304,546]
cards["3s"] := [304,581]
cards["2s"] := [304,616]

; ---------- Board editor coordinates ----------
boardEditorX := 93
boardEditorY := 396
clearBoardX := 404
clearBoardY := 195
OK_X := 401
OK_Y := 628

Delay := 1000

; ---------- File path ----------
filePath := A_ScriptDir . "\flop_tests.txt"
if !FileExist(filePath) {
    MsgBox "File not found! Please check the name and extension."
    ExitApp
}

ShowStep("Opening flop file: " filePath)
fh := FileOpen(filePath, "r")

lineNum := 0
while !fh.AtEOF {
    flop := Trim(fh.ReadLine())
    lineNum++

    if (flop = "") {
        ShowStep("Line " lineNum ": (empty) - skipping")
        Sleep(200)
        continue
    }

    ; --- Safely activate GTO+ window ---
    ShowStep("Line " lineNum ": Finding GTO window...`nFlop: " flop)
    gtoWin := WinExist("ahk_exe GTO.exe")
    if !gtoWin {
        ClearStep()
        MsgBox "GTO window not found! Make sure it is running."
        ExitApp
    }

    ShowStep("Line " lineNum ": Activating GTO...`nFlop: " flop)
    WinRestore(gtoWin)
    WinActivate(gtoWin)
    WinWaitActive(gtoWin, "", 3)
    Sleep(Delay)

    ; --- Interact with board editor ---
    ShowStep("Line " lineNum ": Click Board Editor (" boardEditorX "," boardEditorY ")`nFlop: " flop)
    Click(boardEditorX, boardEditorY)
    Sleep(Delay)

    ShowStep("Line " lineNum ": Click Clear Board (" clearBoardX "," clearBoardY ")`nFlop: " flop)
    Click(clearBoardX, clearBoardY)
    Sleep(Delay)

    ; --- Select flop cards ---
    for index, card in StrSplit(flop, " ") {
        card := Trim(card)
        if (card = "")
            continue

        if !cards.Has(card) {
            ShowStep("Line " lineNum ": ERROR unknown card '" card "'`nFlop: " flop)
            ClearStep()
            MsgBox "Unknown card '" card "' on line " lineNum ".`nLine: " flop
            ExitApp
        }

        x := cards[card][1]
        y := cards[card][2]

        ShowStep("Line " lineNum ": Select card " index "/3: " card "  (" x "," y ")`nFlop: " flop)
        Click(x, y)
        Sleep(Delay)
    }

    ; --- Confirm ---
    ShowStep("Line " lineNum ": Click OK (" OK_X "," OK_Y ")`nFlop: " flop)
    Click(OK_X, OK_Y)

    ; Your existing manual verification pause
    ClearStep()
    MsgBox "Verify Flop`nLine " lineNum ": " flop

    ; If you want tooltip to resume after MsgBox:
    ShowStep("Line " lineNum ": Done. Waiting...")
    Sleep(Delay)
}

fh.Close()
ClearStep()
MsgBox "Done! Processed " lineNum " lines."
