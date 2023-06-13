@echo off

REM Check if the operating system is 64-bit or 32-bit
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "arch=64"
) else (
    set "arch=32"
)

REM Set the download URL based on the architecture
if "%arch%"=="64" (
    set "url=http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/04/windows6.1-kb3140245-x64_5b067ffb69a94a6e5f9da89ce88c658e52a0dec0.msu"
) else (
    set "url=http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/04/windows6.1-kb3140245-x86_cdafb409afbe28db07e2254f40047774a0654f18.msu"
)

REM Download the file using the appropriate URL
echo Downloading...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', 'kb3140245.msu')"

REM Update hostfix
wusa.exe kb3140245.msu /quiet /norestart

REM Delete file hostfix
del kb3140245.msu

REM Add registry keys for TLS 1.1 and TLS 1.2
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" /v SomeValueName /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" /v SomeValueName /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" /v SomeValueName /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" /v SomeValueName /t REG_DWORD /d 1 /f

echo Enable TLS 1.2 successfully, please restart computer...
pause
