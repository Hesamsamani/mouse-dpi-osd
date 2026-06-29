; Mouse DPI OSD — generic / Yichip mice (auto-configured)
#Requires AutoHotkey v2.0
#SingleInstance Force

ConfigIni := A_ScriptDir "\dpi-osd-config.ini"
; Never hook these — they break normal mouse use
global BlockedHotkeys := Map("LButton", 1, "RButton", 1, "WheelUp", 1, "WheelDown", 1)
global DpiSteps := [400, 800, 1200, 1600, 2400, 3200]
global DpiHotkeys := ["XButton1", "XButton2", "MButton"]
global DpiIndex := 2
global PopupMs := 1800
global AlwaysShowHud := true
global HudGui := ""
global PopupGui := ""
global HudText := ""
global ChromaKey := "FEFEFE"

LoadConfig()
InitTray()
if (AlwaysShowHud)
    ShowHud()
UpdateTrayTip()
RegisterHotkeys()

FilterHotkeys(arr) {
    global BlockedHotkeys
    out := []
    for hk in arr {
        if !BlockedHotkeys.Has(hk)
            out.Push(hk)
    }
    return out
}

LoadConfig() {
    global ConfigIni, DpiIndex, DpiSteps, DpiHotkeys, PopupMs, AlwaysShowHud, BlockedHotkeys
    if !FileExist(ConfigIni)
        return
    try {
        idx := IniRead(ConfigIni, "Settings", "DpiIndex", DpiIndex)
        DpiIndex := Integer(idx)
        steps := IniRead(ConfigIni, "Settings", "DpiSteps", "")
        if (steps != "") {
            arr := []
            for part in StrSplit(steps, ",")
                arr.Push(Integer(Trim(part)))
            if (arr.Length > 0)
                DpiSteps := arr
        }
        hk := IniRead(ConfigIni, "Settings", "DpiHotkeys", "")
        if (hk != "") {
            arr := []
            for part in StrSplit(hk, ",")
                arr.Push(Trim(part))
            DpiHotkeys := FilterHotkeys(arr)
        }
        PopupMs := Integer(IniRead(ConfigIni, "Settings", "PopupMs", PopupMs))
        AlwaysShowHud := IniRead(ConfigIni, "Settings", "AlwaysShowHud", "true") = "true"
    }
}

SaveConfig() {
    global ConfigIni, DpiIndex, DpiSteps, DpiHotkeys, PopupMs, AlwaysShowHud
    steps := ""
    for i, v in DpiSteps
        steps .= (i = 1 ? "" : ",") v
    hk := ""
    for i, v in DpiHotkeys
        hk .= (i = 1 ? "" : ",") v
    IniWrite(DpiIndex, ConfigIni, "Settings", "DpiIndex")
    IniWrite(steps, ConfigIni, "Settings", "DpiSteps")
    IniWrite(hk, ConfigIni, "Settings", "DpiHotkeys")
    IniWrite(PopupMs, ConfigIni, "Settings", "PopupMs")
    IniWrite(AlwaysShowHud ? "true" : "false", ConfigIni, "Settings", "AlwaysShowHud")
}

RegisterHotkeys() {
    global DpiHotkeys
    for hk in DpiHotkeys {
        ; ~ = do not block the button — clicks still work normally
        try Hotkey("~" hk, CycleDpi, "On")
    }
}

CycleDpi(*) {
    global DpiIndex, DpiSteps
    DpiIndex++
    if (DpiIndex > DpiSteps.Length)
        DpiIndex := 1
    SaveConfig()
    ShowPopup(CurrentDpi())
    if (AlwaysShowHud)
        ShowHud()
    UpdateTrayTip()
}

CurrentDpi() {
    global DpiIndex, DpiSteps
    return DpiSteps[DpiIndex]
}

InitTray() {
    A_IconTip := "Mouse DPI: " CurrentDpi()
    TraySetIcon("imageres.dll", 109)
    Tray := A_TrayMenu
    Tray.Delete()
    Tray.Add("DPI: " CurrentDpi(), (*) => "")
    Tray.Add("Test popup", (*) => ShowPopup(CurrentDpi()))
    Tray.Add("Map DPI button", (*) => Run('"' A_AhkPath '" "' A_ScriptDir '\Mouse-DPI-Hook-Finder.ahk"'))
    Tray.Add("Edit settings", (*) => Run('notepad.exe "' ConfigIni '"'))
    Tray.Add("Exit", (*) => ExitApp())
}

UpdateTrayTip() {
    dpi := CurrentDpi()
    A_IconTip := "Mouse DPI: " dpi
    try Tray := A_TrayMenu
    catch
        return
    try Tray.Rename(1, "DPI: " dpi)
}

MakeTransparent(gui, chroma) {
    try WinSetTransColor(chroma, gui)
}

ShowPopup(dpi) {
    global PopupGui, PopupMs
    if (IsObject(PopupGui))
        try PopupGui.Destroy()

    ; Compact pill — tight padding, dark glass, readable white label
    panel := "1E1E1E"
    PopupGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    PopupGui.BackColor := panel
    PopupGui.MarginX := 14
    PopupGui.MarginY := 8
    PopupGui.SetFont("s18 norm cFFFFFF", "Segoe UI")
    PopupGui.Add("Text", "Center Background" panel " cFFFFFF", dpi " DPI")
    PopupGui.Show("AutoSize Center NoActivate")
    ; Whole-window alpha: text stays crisp on dark panel; 128 ≈ 50% see-through
    try WinSetTransparent(128, PopupGui)
    SetTimer(HidePopup, -PopupMs)
}

HidePopup() {
    global PopupGui
    if (IsObject(PopupGui)) {
        try PopupGui.Destroy()
        PopupGui := ""
    }
}

ShowHud() {
    global HudGui, HudText, ChromaKey
    dpi := CurrentDpi()
    if (!IsObject(HudGui)) {
        HudGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        HudGui.BackColor := ChromaKey
        HudGui.SetFont("s12 norm c00E5FF", "Segoe UI")
        HudText := HudGui.Add("Text", "w104 h28 Center Background" ChromaKey " c00E5FF", dpi " DPI")
        HudGui.Show("x" (A_ScreenWidth - 120) " y" (A_ScreenHeight - 100) " NoActivate")
        MakeTransparent(HudGui, ChromaKey)
    } else {
        HudText.Text := dpi " DPI"
    }
}

OnExit(*) => SaveConfig()