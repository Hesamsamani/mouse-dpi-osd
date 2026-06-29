; Detects which mouse button your DPI key sends to Windows (side buttons only).
#Requires AutoHotkey v2.0
#SingleInstance Force

ConfigIni := A_ScriptDir "\dpi-osd-config.ini"
Blocked := Map("LButton", 1, "RButton", 1, "WheelUp", 1, "WheelDown", 1)
buttons := ["MButton", "XButton1", "XButton2"]

for b in buttons
    try Hotkey("~" b, ButtonPressed.Bind(b), "On")

TraySetIcon("imageres.dll", 78)
A_IconTip := "Press DPI / side button (not left/right click)"
A_TrayMenu.Delete()
A_TrayMenu.Add("Press DPI or side mouse button", (*) => "")
A_TrayMenu.Add("Exit", (*) => ExitApp())

ToolTip("Press DPI or SIDE button only.`nLeft/right click are ignored.", A_ScreenWidth//2 - 200, 80)
SetTimer(() => ToolTip(), -6000)

ButtonPressed(name, *) {
    global ConfigIni, Blocked
    if Blocked.Has(name)
        return
    existing := IniRead(ConfigIni, "Settings", "DpiHotkeys", "XButton1,XButton2,MButton")
    list := []
    for part in StrSplit(existing, ",") {
        p := Trim(part)
        if (p != "" && !Blocked.Has(p))
            list.Push(p)
    }
    found := false
    for v in list {
        if (v = name) {
            found := true
            break
        }
    }
    if !found
        list.Push(name)
    hk := ""
    for i, v in list
        hk .= (i = 1 ? "" : ",") v
    if !FileExist(ConfigIni)
        FileAppend("", ConfigIni)
    IniWrite(hk, ConfigIni, "Settings", "DpiHotkeys")
    ToolTip("Saved: " name "`nRestart Mouse DPI OSD from tray.", A_ScreenWidth//2 - 160, A_ScreenHeight//2)
    SetTimer(() => ToolTip(), -3500)
    try Tray.Rename(1, "Saved: " name)
}