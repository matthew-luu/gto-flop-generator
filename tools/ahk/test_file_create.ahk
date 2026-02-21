#Requires AutoHotkey v2.0
^!s::ExitApp  ; Ctrl+Alt+S stops the script

SendMode("Input")
SetWorkingDir(A_ScriptDir)

; IMPORTANT: your coords work in Client mode
CoordMode("Mouse", "Client")
SetDefaultMouseSpeed 0

; =========================
; CONFIG YOU SHOULD EDIT
; =========================

; Template GTO file to open each iteration (absolute path recommended)
templatePath := A_ScriptDir . "\BTN_vs_BB_SRP_Template.gto"

; Output folder for generated files
outputDir := A_ScriptDir . "\generated"
if !DirExist(outputDir)
    DirCreate(outputDir)

; Delays (ms)
Delay := 100
AfterOpenDelay := 1200
AfterSaveDelay := 900

; =========================
; COORDINATES (CLIENT)
; =========================

; Board editor panel
boardEditorX := 93
boardEditorY := 396
clearBoardX := 404
clearBoardY := 195
OK_X := 401
OK_Y := 628
buildTreeOneX := 80
buildTreeOneY := 430
buildTreeTwoX := 820
buildTreeTwoY := 910
buildTreeThreeX := 867
buildTreeThreeY := 806

; File menu + Save As (you can tweak these)
fileMenuX := 15
fileMenuY := -10
saveAsX := 100
saveAsY := 75

; =========================
; HELPERS
; =========================
ShowStep(text, x := 10, y := 10) {
    ToolTip text, x, y
}
ClearStep() {
    ToolTip
}
ClickAt(x, y) {
    MouseMove x, y, 0
    Sleep 80
    Click
}

; paste-based typing is more reliable than Send "raw text"
TypeText(text) {
    oldClip := A_Clipboard
    A_Clipboard := text
    Sleep 50
    Send "^v"
    Sleep 50
    A_Clipboard := oldClip
}

OpenTemplate(templateFullPath, lineNum, flop) {
    global Delay

    ShowStep("Line " lineNum ": OPEN template (Ctrl+O)`n" templateFullPath "`nFlop: " flop)
    Send "^o"

    ; Wait for the common Windows file dialog (#32770) to become active
    if !WinWaitActive("ahk_class #32770", "", 3) {
        ClearStep()
        MsgBox "Open dialog did not appear (timeout)."
        ExitApp
    }

    Sleep 80
    Send "^a"
    Sleep 30
    TypeText(templateFullPath)
    Sleep 80
    Send "{Enter}"

    ; Wait for dialog to close so we don't type into it later
    WinWaitClose("ahk_class #32770", "", 5)
    Sleep Delay
}

BuildTree(){
    global buildTreeOneX, buildTreeOneY, buildTreeTwoX, buildTreeTwoY, buildTreeThreeX, buildTreeThreeY, Delay

    ShowStep("BuildTree: step 1")
    ClickAt(buildTreeOneX, buildTreeOneY)
    Sleep Delay

    ShowStep("BuildTree: step 2")
    ClickAt(buildTreeTwoX, buildTreeTwoY)
    Sleep Delay

    ShowStep("BuildTree: step 3")
    ClickAt(buildTreeThreeX, buildTreeThreeY)
    Sleep Delay
}


SaveAsViaMenu(outputFullPath, lineNum, flop) {
    global fileMenuX, fileMenuY, saveAsX, saveAsY, Delay

    ShowStep("Line " lineNum ": File -> Save As`nFlop: " flop)
    ClickAt(fileMenuX, fileMenuY)
    Sleep Delay

    ShowStep("Line " lineNum ": Click Save As`nFlop: " flop)
    ClickAt(saveAsX, saveAsY)

    ; Wait for Save dialog
    if !WinWaitActive("ahk_class #32770", "", 3) {
        ClearStep()
        MsgBox "Save As dialog did not appear (timeout)."
        ExitApp
    }

    ; Attempt save with retries based on file existence
    maxAttempts := 4
    attempt := 1

    while (attempt <= maxAttempts) {
        ShowStep("Line " lineNum ": Save attempt " attempt "/" maxAttempts "`n" outputFullPath "`nFlop: " flop)

        ; Ensure dialog is active (refocus if needed)
        WinActivate("ahk_class #32770")
        WinWaitActive("ahk_class #32770", "", 2)

        ; Try to land focus on filename field:
        ; (This pattern is robust even if focus starts in file list/tree)
        Send "+{Tab 6}"
        Sleep 60
        Send "{Tab 6}"
        Sleep 60

        ; Replace whatever is in the filename box
        Send "^a"
        Sleep 50
        TypeText(outputFullPath)
        Sleep 120

        ; Press Enter to commit
        Send "{Enter}"
        Sleep 250

        ; Sometimes the dialog closes before the file is fully written, so wait a bit
        ; but don't block too long.
        if WaitForFileExist(outputFullPath, 1200) {
            ; Optionally wait until size stabilizes (more robust)
            WaitForFileStable(outputFullPath, 2500)
            return
        }

        ; If still not saved, try again after a short pause.
        Sleep 300
        attempt++
    }

    ClearStep()
    MsgBox "Failed to save after " maxAttempts " attempts:`n" outputFullPath
    ExitApp
}

WaitForFileExist(path, timeoutMs := 1200) {
    start := A_TickCount
    while (A_TickCount - start < timeoutMs) {
        if FileExist(path)
            return true
        Sleep 80
    }
    return false
}

WaitForFileStable(path, timeoutMs := 2500) {
    start := A_TickCount
    lastSize := -1
    stableCount := 0

    while (A_TickCount - start < timeoutMs) {
        if FileExist(path) {
            size := FileGetSize(path)
            if (size = lastSize && size > 0) {
                stableCount++
                if (stableCount >= 3) ; stable for 3 checks
                    return true
            } else {
                stableCount := 0
                lastSize := size
            }
        }
        Sleep 120
    }
    return false
}

; =========================
; NAMING (ranks only + texture; TT band = which two cards are suited)
; =========================
RankValue(rankChar) {
    switch rankChar {
        case "A": return 14
        case "K": return 13
        case "Q": return 12
        case "J": return 11
        case "T": return 10
        default:  return Integer(rankChar) ; "9".."2"
    }
}

; Robust parse: handles any spacing, validates card tokens, normalizes case.
ParseFlopCards(flop, lineNum := 0) {
    cardsArr := []

    ; Find all occurrences of a card token anywhere in the line
    pos := 1
    while RegExMatch(flop, "i)([AKQJT2-9])([hdcs])", &m, pos) {
        r := StrUpper(m[1])
        s := StrLower(m[2])
        cardsArr.Push(r . s)
        pos := m.Pos + m.Len
    }

    if (cardsArr.Length != 3) {
        ClearStep()
        MsgBox "Expected 3 cards on line " lineNum " but found " cardsArr.Length ".`nLine: " flop
        ExitApp
    }

    return cardsArr
}


IsPairedBoard(cardsArr) {
    r1 := SubStr(cardsArr[1], 1, 1)
    r2 := SubStr(cardsArr[2], 1, 1)
    r3 := SubStr(cardsArr[3], 1, 1)
    return (r1 = r2) || (r1 = r3) || (r2 = r3)
}

SortCardsByRankDesc(cardsArr) {
    a := []
    for _, c in cardsArr {
        r := SubStr(c, 1, 1)
        s := SubStr(c, 2, 1)
        a.Push({ card: c, r: r, s: s, v: RankValue(r) })
    }

    ; bubble sort 3 items by rank value desc
    Loop 2 {
        if (a[1].v < a[2].v) {
            tmp := a[1], a[1] := a[2], a[2] := tmp
        }
        if (a[2].v < a[3].v) {
            tmp := a[2], a[2] := a[3], a[3] := tmp
        }
    }
    return a
}

GetTextureSuffix(cardsArr) {
    ; Returns: M | R | TT | TT_HM | TT_ML | TT_HL
    ; Throws if anything is inconsistent

    suitCounts := Map()
    vals := []
    suits := []

    for _, c in cardsArr {
        r := SubStr(c, 1, 1)
        s := SubStr(c, 2, 1)
        v := RankValue(r)
        vals.Push(v)
        suits.Push(s)
        suitCounts[s] := (suitCounts.Has(s) ? suitCounts[s] + 1 : 1)
    }

    if (suitCounts.Count = 1)
        return "M"
    if (suitCounts.Count = 3)
        return "R"
    if (suitCounts.Count != 2) {
        msg := "Invalid suit distribution count: " . suitCounts.Count
        throw Error(msg)
    }

    ; Two-tone
    if IsPairedBoard(cardsArr)
        return "TT"  ; paired => omit band

    ; Identify doubled suit
    twoSuit := ""
    for s, cnt in suitCounts {
        if (cnt = 2) {
            twoSuit := s
            break
        }
    }
    if (twoSuit = "") {
        msg := "Two-tone but no doubled suit found"
        throw Error(msg)
    }

    ; Collect rank values of suited cards
    suitedVals := []
    Loop 3 {
        if (suits[A_Index] = twoSuit)
            suitedVals.Push(vals[A_Index])
    }
    if (suitedVals.Length != 2) {
        msg := "Expected exactly 2 suited cards, got " . suitedVals.Length
        throw Error(msg)
    }

    ; Compute high/mid/low values
    highVal := vals[1]
    lowVal := vals[1]
    for _, v in vals {
        if (v > highVal)
            highVal := v
        if (v < lowVal)
            lowVal := v
    }
    midVal := (vals[1] + vals[2] + vals[3]) - highVal - lowVal

    hasHigh := (suitedVals[1] = highVal) || (suitedVals[2] = highVal)
    hasMid  := (suitedVals[1] = midVal)  || (suitedVals[2] = midVal)
    hasLow  := (suitedVals[1] = lowVal)  || (suitedVals[2] = lowVal)

    if (hasHigh && hasMid)
        return "TT_HM"
    if (hasMid && hasLow)
        return "TT_ML"
    if (hasHigh && hasLow)
        return "TT_HL"

    msg := "Could not classify TT band"
    throw Error(msg)
}

BuildFileName(flop, lineNum := 0) {
    cardsArr := ParseFlopCards(flop, lineNum)
    sorted := SortCardsByRankDesc(cardsArr)
    rankKey := sorted[1].r . sorted[2].r . sorted[3].r
    tex := GetTextureSuffix(cardsArr)
    return lineNum ".SRP_" rankKey "_" tex
}


; =========================
; CARD MAP (CLIENT COORDS)
; =========================
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

; =========================
; INPUT FILE
; =========================
filePath := A_ScriptDir . "\flops_1755.txt"
if !FileExist(filePath) {
    MsgBox "File not found: " filePath
    ExitApp
}
if !FileExist(templatePath) {
    MsgBox "Template not found: " templatePath "`nEdit templatePath at top of script."
    ExitApp
}

; =========================
; MAIN LOOP
; =========================
fh := FileOpen(filePath, "r")

lineNum := 0
while !fh.AtEOF {
    flop := Trim(fh.ReadLine())
    lineNum++

    if (flop = "") {
        ShowStep("Line " lineNum ": (empty) - skipping")
        Sleep 150
        continue
    }

    ; Activate GTO
    ShowStep("Line " lineNum ": Finding/activating GTO...`nFlop: " flop)
    gtoWin := WinExist("ahk_exe GTO.exe")
    if !gtoWin {
        ClearStep()
        MsgBox "GTO window not found! Make sure it is running."
        ExitApp
    }

    WinRestore(gtoWin)
    WinActivate(gtoWin)
    WinWaitActive(gtoWin, "", 3)
    Sleep Delay

    ; 1) Open template
    OpenTemplate(templatePath, lineNum, flop)
    Sleep AfterOpenDelay

    ; Ensure active after dialog
    WinActivate(gtoWin)
    WinWaitActive(gtoWin, "", 3)
    Sleep Delay

    ; 2) Set board
    ShowStep("Line " lineNum ": Board Editor`nFlop: " flop)
    ClickAt(boardEditorX, boardEditorY)
    Sleep Delay

    ShowStep("Line " lineNum ": Clear Board`nFlop: " flop)
    ClickAt(clearBoardX, clearBoardY)
    Sleep Delay

    cardsToClick := ParseFlopCards(flop, lineNum)
    idx := 0
    for _, card in cardsToClick {
        idx++
        if !cards.Has(card) {
            ClearStep()
            MsgBox "Unknown card '" card "' on line " lineNum ".`nCard: " card "`nLine: " flop
            ExitApp
        }

        x := cards[card][1]
        y := cards[card][2]
        ShowStep("Line " lineNum ": Select " idx "/3: " card " (" x "," y ")`nFlop: " flop)
        ClickAt(x, y)
        Sleep 250
    }


    ShowStep("Line " lineNum ": OK`nFlop: " flop)
    ClickAt(OK_X, OK_Y)
    Sleep Delay

    ; 3) Save As via menu clicks with new naming convention
    baseName := BuildFileName(flop, lineNum)
    outFile := outputDir . "\" . baseName . ".gto"


    BuildTree()
    SaveAsViaMenu(outFile, lineNum, flop)
    WinActivate("ahk_exe GTO.exe")
    WinWaitActive("ahk_exe GTO.exe", "", 3)
    Sleep 150
    Sleep AfterSaveDelay

    ; Prototype pause
    ClearStep()
    ; MsgBox "Saved:`n" outFile "`n`nVerify and press OK to continue."
}

fh.Close()
ClearStep()
MsgBox "Done! Processed " lineNum " lines."
