; Low-level mouse hook — detects dedicated DPI / side buttons (not left/right click).
#Requires AutoHotkey v2.0
#SingleInstance Force

ConfigIni := A_ScriptDir "\dpi-osd-config.ini"
global LastBtn := ""
global hHook := 0
global HookProc := 0

DetectorGui := Gui("+AlwaysOnTop", "DPI Button Detector")
DetectorGui.SetFont("s10", "Segoe UI")
DetectorGui.Add("Text", "w440", "Press your DEDICATED DPI button below.`nDo NOT use left click, right click, or scroll wheel click.")
list := DetectorGui.Add("ListBox", "w440 h220")
DetectorGui.Add("Button", "w440", "Save detected button & restart OSD").OnEvent("Click", SaveAndRestart)
DetectorGui.Add("Text", "w440 cGray", "If nothing appears when you press DPI, that button is hardware-only (see README).")
DetectorGui.Show()

HookProc := CallbackCreate(MouseLLHook, "F", 4)
hHook := DllCall("SetWindowsHookEx", "Int", 14, "Ptr", HookProc, "Ptr", 0, "UInt", 0, "Ptr")
if !hHook {
    MsgBox "Could not install mouse hook. Run as normal user (not elevated).", "Error", 16
    ExitApp
}

OnExit(ExitHook)

MouseLLHook(nCode, wParam, lParam) {
    global LastBtn, list
    if (nCode < 0)
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
    btn := MsgToButton(wParam, lParam)
    if (btn = "")
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
    if (btn = "LButton" || btn = "RButton")
        return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
    LastBtn := btn
    line := Format("{}  →  {}", SubStr(A_Now, 12), btn)
    list.Add([line])
    list.Opt("Choose", list.GetCount())
    return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

MsgToButton(wParam, lParam) {
    if (wParam = 0x0207)
        return "MButton"
    if (wParam = 0x020B) {
        mouseData := NumGet(lParam, 8, "UInt")
        x := (mouseData >> 16) & 0xFFFF
        return "XButton" x
    }
    if (wParam = 0x0201)
        return "LButton"
    if (wParam = 0x0204)
        return "RButton"
    return ""
}

SaveAndRestart(*) {
    global LastBtn, ConfigIni
    if (LastBtn = "") {
        MsgBox "No button detected yet. Press your DPI button first.", "DPI Button Detector", 48
        return
    }
    if !FileExist(ConfigIni)
        FileAppend("", ConfigIni)
    IniWrite(LastBtn, ConfigIni, "Settings", "DpiHotkeys")
    MsgBox "Saved DPI hotkey: " LastBtn "`n`nOnly this button will change the DPI overlay now.", "Saved", 64
    RestartOsd()
    ExitApp
}

RestartOsd() {
    osd := A_ScriptDir "\Mouse-DPI-OSD.ahk"
    for p in WinGetList("ahk_exe AutoHotkey64.exe") {
        cmd := WinGetCommandLine("ahk_id " p)
        if InStr(cmd, "Mouse-DPI-OSD.ahk")
            ProcessClose(WinGetPID("ahk_id " p))
    }
    Sleep 400
    Run('"' A_AhkPath '" "' osd '"')
}

ExitHook(*) {
    global hHook, HookProc
    if hHook
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
    if HookProc
        CallbackFree(HookProc)
}