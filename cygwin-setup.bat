::Cygwin Setup.exe Downloader
@ECHO OFF
SetLocal EnableDelayedExpansion
CLS

CALL :DOWNLOAD
CALL :SETUP

EXIT/B

::Funktions (or some thing like that M)

::A wget for Powershell
::loads the 32Bit Version
:DOWNLOAD32
        ECHO.Downloading: setup.exe
        powershell.exe -Command "(new-object System.Net.WebClient).DownloadFile('http://www.cygwin.com/setup-x86.exe, 'setup-x86.exe')" >NUL
        IF NOT %ERRORLEVEL% EQU 0 ( CALL :ERR_DOWNLOAD ) ELSE ( ECHO.Download OK ... )
EXIT/B

::A wget for Powershell
::loads the 64Bit Version
:DOWNLOAD64
        ECHO.Downloading: setup-x86_64.exe
        powershell.exe -Command "(new-object System.Net.WebClient).DownloadFile('http://www.cygwin.com/setup-x86_64.exe', 'setup-x86_64.exe')" >NUL
        IF NOT %ERRORLEVEL% EQU 0 ( CALL :ERR_DOWNLOAD ) ELSE ( ECHO.Download OK ... )
EXIT/B

::Wrapper for 32/64Bit selection
::TODO: Etablish parameter driven system selection for 32/64Bit systems
:DOWNLOAD
        ::CALL :DOWNLOAD32
        CALL :DOWNLOAD64
EXIT/B

::Call 32/64bit setup.exe
::TODO: Handle 32/64Bit
:SETUP
        IF %ERRORLEVEL% EQU 0 (
            ECHO.Starting: setup-xY.exe ...
            ::start setup-x86.exe
            START setup-x86_64.exe
        )
EXIT/B

:: Fehlerbehandlung
:ERR_DOWNLOAD
        ECHO.Fehler beim download!
        EXIT/B 10
EXIT/B

