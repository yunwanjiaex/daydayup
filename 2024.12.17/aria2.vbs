Set p = CreateObject("WScript.Shell")
p.Run "taskkill /f /im aria2c.exe",,True
p.Run "aria2c.exe --conf-path=aria2.conf",0