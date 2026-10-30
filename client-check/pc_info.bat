@echo off
chcp 1251 > nul

REM =========================================================
REM Тема: Диагностика клиентского компьютера
REM Автор: [Карпов]
REM =========================================================

set "REP=%~dp0pc_report.txt"

echo COMPUTER DIAGNOSTICS > "%REP%"
echo ==================================== >> "%REP%"
echo COMPUTER DIAGNOSTICS
echo ====================================

echo.
echo [OPERATING SYSTEM]
echo. >> "%REP%"
echo [OPERATING SYSTEM] >> "%REPORT_FILE%"
wmic os get Caption,Version /format:list
wmic os get Caption,Version /format:list >> "%REP%"

echo.
echo [PROCESSOR]
echo. >> "%REP%"
echo [PROCESSOR] >> "%REP%"
wmic cpu get Name /format:list
wmic cpu get Name /format:list >> "%REP%"

echo.
echo [MEMORY]
echo. >> "%REP%"
echo [MEMORY] >> "%REP%"
for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /format:list') do set /a "t_gb=%%i / 1048576"
for /f "tokens=2 delims==" %%i in ('wmic os get FreePhysicalMemory /format:list') do set /a "f_gb=%%i / 1048576"
echo Total Memory: %t_gb% GB
echo Total Memory: %t_gb% GB >> "%REP%"
echo Free Memory: %f_gb% GB
echo Free Memory: %f_gb% GB >> "%REP%"

echo.
echo [DISK C]
echo. >> "%REP%"
echo [DISK C] >> "%REP%"
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where "DeviceID='C:'" get Size /format:list') do set /a "sz_gb=%%i / 1073741824"
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /format:list') do set /a "fr_gb=%%i / 1073741824"
echo Total Disk C: %sz_gb% GB
echo Total Disk C: %sz_gb% GB >> "%REP%"
echo Free Disk C: %fr_gb% GB
echo Free Disk C: %fr_gb% GB >> "%REP%"

echo.
echo [INSTALLED PROGRAMS]
echo Searching apps... Please wait...
echo. >> "%REP%"
echo [INSTALLED PROGRAMS] >> "%REP%"
for /f "tokens=2,*" %%a in ('reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall /s /f DisplayName ^| findstr "DisplayName"') do (
    echo %%b
    echo %%b >> "%REP%"
)

echo.
echo ====================================
echo Report saved successfully to pc_report.txt
echo ====================================

pause
