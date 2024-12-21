import sys

u = sys.argv[1]
g = sys.argv[2]

import winreg

p = winreg.OpenKeyEx(
    winreg.HKEY_CURRENT_USER, r"SOFTWARE\\Valve\\Steam", 0, winreg.KEY_ALL_ACCESS
)
winreg.SetValueEx(p, "AutoLoginUser", 0, winreg.REG_SZ, u)
winreg.SetValueEx(p, "AutoLoginUser_steamchina", 0, winreg.REG_SZ, u)
winreg.CloseKey(p)

import re

with open(
    r"C:\\Program Files (x86)\\Steam\\config\\loginusers.vdf", "r", encoding="utf-8"
) as f:
    lines = f.readlines()

with open(
    r"C:\\Program Files (x86)\\Steam\\config\\loginusers.vdf", "w", encoding="utf-8"
) as f:
    tt = 0
    for l in lines:
        if re.search(f'"AccountName"\\s+"{u}"', l):
            tt = 1
        elif tt == 1 and re.search(
            f'"(RememberPassword|WantsOfflineMode|SkipOfflineModeWarning|AllowAutoLogin)"',
            l,
        ):
            l = re.sub('"0"', '"1"', l)
        elif tt == 1 and re.search(r"\}", l):
            tt = 0
        f.write(l)

import subprocess

subprocess.run(f'start steam://run/{g}" -silent', shell=True)
