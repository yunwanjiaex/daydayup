; 自定义 CapsLock 键
SetCapsLockState "AlwaysOff"

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

; 定时移动鼠标以保持屏幕常亮
CapsLock & m:: {
    f := A_Temp . "\mouse.exist"
    if FileExist(f) {
        SetTimer mouse_move, 0
        FileDelete(f)
    } else {
        ; 每1分钟动一下鼠标
        SetTimer mouse_move, 60000
        FileAppend("", f)
    }
    mouse_move() {
        MouseMove 1, 1, 100, "R"
    }

}

CapsLock & e:: Run('explorer.exe ' A_MyDocuments '\..\Downloads')