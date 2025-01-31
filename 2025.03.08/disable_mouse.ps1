$code = @"
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
"@
$userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru
$userInput::BlockInput($true)
(New-Object -ComObject wscript.shell).popup("按 Ctrl + Alt + Delete 恢复响应")
$userInput::BlockInput($false)