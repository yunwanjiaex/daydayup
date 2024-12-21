# 提权到 TrustedInstaller
### 普通用户提权到 Administrator
```powershell
if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath powershell.exe -Verb Runas -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" `"$($MyInvocation.MyCommand.UnboundArguments)`""
    exit
}
# 脚本剩下的内容
```
### Administrator 提权到 TrustedInstaller
```cpp
#include <windows.h>

void set_privilege(LPCTSTR p) {
    // 开启权限
    HANDLE h;
    OpenProcessToken(GetCurrentProcess(), TOKEN_ALL_ACCESS, &h);
    TOKEN_PRIVILEGES t;
    t.PrivilegeCount = 1;
    LookupPrivilegeValueW(NULL, p, &t.Privileges[0].Luid);
    t.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(h, NULL, &t, sizeof(TOKEN_PRIVILEGES), NULL, NULL);
}

void copy_privilege(DWORD pid, LPWSTR cl) {
    // 复制进程pid的权限创建cl进程
    HANDLE hp, ht, hd;
    hp = OpenProcess(TOKEN_ALL_ACCESS, FALSE, pid);
    OpenProcessToken(hp, MAXIMUM_ALLOWED, &ht);
    DuplicateTokenEx(ht, MAXIMUM_ALLOWED, NULL, SecurityImpersonation, TokenPrimary, &hd);
    CreateProcessWithTokenW(hd, LOGON_WITH_PROFILE, NULL, cl, CREATE_UNICODE_ENVIRONMENT, NULL, NULL, NULL, NULL);
}

int wmain(int argc, wchar_t *argv[]) {
    set_privilege(SE_DEBUG_NAME);
    set_privilege(SE_IMPERSONATE_NAME);
    copy_privilege(_wtoi(argv[1]), argv[2]);
    return 0;
}
```
* 编译得到 `a.exe` ,代码仅用作原理演示,省略了诸多环境判断,因此在很多情况下是执行失败的
* 运行 `.\a.exe 1234 "explorer.exe C:\"` ,以pid为1234的进程的权限来执行命令 `explorer.exe C:\`
* 打开 TrustedInstaller 权限的 cmd
    ```powershell
    sc.exe start TrustedInstaller
    $t = Get-Process -Name TrustedInstaller | Select-Object -ExpandProperty id -First 1
    $w = Get-Process -Name winlogon         | Select-Object -ExpandProperty id -First 1
    .\a.exe $w ".\a.exe $t `"cmd.exe`""
    ```
* 验证提权是否成功
    ```powershell
    whoami /groups | findstr TrustedInstaller
    ```
* 第三方工具如 [superUser](https://github.com/mspaintmsi/superUser) ,召唤具有最高权限的 cmd
    ```cmd
    @"%~dp0"superUser64.exe /ws cmd.exe
    ```