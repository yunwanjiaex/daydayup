# Windows 修改按键映射
### 格式
* 初始形态如下,前8个00和后4个00是固定值
    ```reg
    Windows Registry Editor Version 5.00

    [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
    "Scancode Map"=hex:00,00,00,00,00,00,00,00,01,00,00,00,00,00,00,00
    ```
* `01,00,00,00` 代表没有映射, `02,00,00,00` 是有1个, `03,00,00,00` 是有2个,以此类推, `0b,00,00,00` 是有10个
* 中间部分每4个一组,前2个是映射后的键位码,后2个是原键位码
* 如 `CapsLock` 是 `3a` ,左 `Ctrl `是 `1d` ,交换它们的按键注册表值为 `00,00,00,00,00,00,00,00,03,00,00,00,3a,00,1d,00,1d,00,3a,00,00,00,00,00`
* 如需屏蔽某按键,只需将映射后的键位码设成 `00,00` ,对于多位按键比如静音 `Mute` 码为 `e020` ,注册表实际写作 `20,e0`
* 重启后生效
### 按键测试
```powershell
$API = Add-Type -MemberDefinition @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
'@ -Name 'Win32' -Namespace API -PassThru

while (1) {
    Start-Sleep -Milliseconds 40
    for ($a = 254; $a -ge 1; $a--) {
        if ($API::GetAsyncKeyState($a) -eq -32767) {
            Write-Host Scan Code: $API::MapVirtualKey($a, 4).ToString('x') / Virtual Key: $a.ToString('x')
        }
    }
}
```
按一个键,会显示它的[键位码](https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html)和[虚拟键代码](https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes)