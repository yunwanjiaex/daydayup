; 自定义 CapsLock 键
SetCapsLockState "AlwaysOff"
#SingleInstance force
#NoTrayIcon

; 打开记事本保存一些临时文本
CapsLock & n:: {
    ; 在这个目录下 C:\Users\kunkun\AppData\Local\Temp
    f := A_Temp . "\xtx.txt"
    try {
        pid := FileRead(f . ".exist")
        WinActivate("ahk_pid " . pid)
        return
    }

    FileAppend("", f)
    Run("notepad.exe " . f, , , &pid)
    FileDelete(f . ".exist*")
    FileAppend(pid, f . ".exist")
    WinWait("ahk_pid " . pid) and WinActivate

    ; 每10秒自动保存
    SetTimer autosave_xtxtxt, 10000
    autosave_xtxtxt() {
        if (WinExist("ahk_pid " . pid))
            ControlSend "^s"
        else
            SetTimer , 0
    }
}

; 隐藏当前活动窗口,所谓老板键
CapsLock & h:: {
    wid := WinGetID("A")
    FileAppend(wid . "`n", A_Temp . "\hide_aw.exist")
    WinHide wid
    ; 静音
    SoundSetMute true
}

; 将隐藏的窗口全部显示出来
CapsLock & s:: {
    try
        t := FileRead(A_Temp . "\hide_aw.exist")
    catch
        return
    for i, aw in StrSplit(t, "`n")
        try WinShow aw * 1
    FileDelete(A_Temp . "\hide_aw.exist")
    ; 恢复音量
    SoundSetMute false
}

CapsLock & e:: Run('explorer.exe ' A_MyDocuments '\..\Downloads')
CapsLock & t:: Run(A_MyDocuments '\terminal\wt.exe -d ' A_MyDocuments '\..\Downloads')
CapsLock & p:: { ; 直接睡眠唤醒后 CapsLock 会处于打开状态
    SetTimer gotosleep, -500
    gotosleep() {
        DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 1)
    }
}
