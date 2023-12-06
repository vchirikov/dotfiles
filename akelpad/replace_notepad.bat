@echo off
takeown /f c:\windows\SysWOW64\notepad.exe
cacls c:\windows\SysWOW64\notepad.exe /G Administrators:F

takeown /f c:\windows\System32\notepad.exe
cacls c:\windows\System32\notepad.exe /G Administrators:F

takeown /f c:\windows\notepad.exe
cacls c:\windows\notepad.exe /G Administrators:F

copy c:\Windows\SysWOW64\notepad.exe c:\windows\syswow64\notepad.exe.backup
copy c:\Windows\System32\notepad.exe c:\windows\system32\notepad.exe.backup
copy c:\Windows\notepad.exe c:\windows\notepad.exe.backup

mklink C:\Windows\System32\notepad.exe "C:\Program Files\AkelPad\AkelPad.exe"
mklink C:\Windows\SysWOW64\notepad.exe "C:\Program Files\AkelPad\AkelPad.exe"
mklink C:\Windows\notepad.exe "C:\Program Files\AkelPad\AkelPad.exe"

mklink /D C:\Windows\System32\AkelFiles "C:\Program Files\AkelPad\AkelFiles"
mklink /D C:\Windows\SysWOW64\AkelFiles "C:\Program Files\AkelPad\AkelFiles"
mklink /D C:\Windows\AkelFiles "C:\Program Files\AkelPad\AkelFiles"

