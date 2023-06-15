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
echo Update Hotfix and enable TLS 1.2...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', 'kb3140245.msu')"

REM Update hostfix
wusa.exe kb3140245.msu /quiet /norestart

REM Delete file hostfix
del kb3140245.msu

REM Add registry keys
setlocal
for /f "delims=" %%a in ('wmic os get osarchitecture /value ^| findstr /i "OsArchitecture"') do set "arch=%%a"
set "reg32bWinHttp=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
set "reg64bWinHttp=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
set "regWinHttpDefault=DefaultSecureProtocols"
set "regWinHttpValue=0x00000a00"
set "regTLS11=HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client"
set "regTLS12=HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
set "regTLSDefault=DisabledByDefault"
set "regTLSValue=0x00000000"
echo Creating Registry Keys...
echo.
reg query "%reg32bWinHttp%" >nul 2>nul
if %errorlevel% equ 1 (
    reg add "%reg32bWinHttp%" /v "%regWinHttpDefault%" /t REG_DWORD /d %regWinHttpValue% /f >nul
) else (
    reg add "%reg32bWinHttp%" /v "%regWinHttpDefault%" /t REG_DWORD /d %regWinHttpValue% /f >nul
)

if /i "%arch%" equ "64-bit" (
    echo Creating registry key %reg64bWinHttp%\%regWinHttpDefault% with value %regWinHttpValue%
    reg query "%reg64bWinHttp%" >nul 2>nul
    if %errorlevel% equ 1 (
        reg add "%reg64bWinHttp%" /v "%regWinHttpDefault%" /t REG_DWORD /d %regWinHttpValue% /f >nul
    ) else (
        reg add "%reg64bWinHttp%" /v "%regWinHttpDefault%" /t REG_DWORD /d %regWinHttpValue% /f >nul
    )
)

reg query "%regTLS11%" >nul 2>nul
if %errorlevel% equ 1 (
    reg add "%regTLS11%" /v "%regTLSDefault%" /t REG_DWORD /d %regTLSValue% /f >nul
) else (
    reg add "%regTLS11%" /v "%regTLSDefault%" /t REG_DWORD /d %regTLSValue% /f >nul
)
reg query "%regTLS12%" >nul 2>nul
if %errorlevel% equ 1 (
    reg add "%regTLS12%" /v "%regTLSDefault%" /t REG_DWORD /d %regTLSValue% /f >nul
) else (
    reg add "%regTLS12%" /v "%regTLSDefault%" /t REG_DWORD /d %regTLSValue% /f >nul
)

echo Enable TLS 1.2 successfully, please restart computer...
pause
