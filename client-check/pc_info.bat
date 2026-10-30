@echo off
chcp 65001 > nul

REM =========================================================
REM Тема: Инструментальные средства ревьюирования
REM Автор: [Твоя Фамилия]
REM Дата: 30.10.2026
REM =========================================================

set "REP=%~dp0pc_report.txt"

echo Диагностика компьютера > "%REP%"
echo ==================================== >> "%REP%"
echo Диагностика компьютера
echo ====================================

echo.
echo [Операционная система]
echo. >> "%REP%"
echo [Операционная система] >> "%REP%"
wmic os get Caption,Version /format:list > "%~dp0os.txt"
type "%~dp0os.txt"
type "%~dp0os.txt" >> "%REP%"
del "%~dp0os.txt"

echo.
echo [Процессор]
echo. >> "%REP%"
echo [Процессор] >> "%REP%"
wmic cpu get Name /format:list > "%~dp0cpu.txt"
type "%~dp0cpu.txt"
type "%~dp0cpu.txt" >> "%REP%"
del "%~dp0cpu.txt"

echo.
echo [Оперативная память]
echo. >> "%REP%"
echo [Оперативная память] >> "%REP%"
for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /format:list') do set "t_mem=%%i"
for /f "tokens=2 delims==" %%i in ('wmic os get FreePhysicalMemory /format:list') do set "f_mem=%%i"
set /a t_gb=%t_mem% / 1048576
set /a f_gb=%f_mem% / 1048576
echo Всего памяти: %t_gb% ГБ
echo Всего памяти: %t_gb% ГБ >> "%REP%"
echo Свободно памяти: %f_gb% ГБ
echo Свободно памяти: %f_gb% ГБ >> "%REP%"

echo.
echo [Диск C]
echo. >> "%REP%"
echo [Диск C] >> "%REP%"
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where "DeviceID='C:'" get Size /format:list') do set "d_sz=%%i"
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /format:list') do set "d_fr=%%i"
set /a sz_gb=%d_sz% / 1073741824
set /a fr_gb=%d_fr% / 1073741824
echo Общий размер диска C: %sz_gb% ГБ
echo Общий размер диска C: %sz_gb% ГБ >> "%REP%"
echo Свободно на диске C: %fr_gb% ГБ
echo Свободно на диске C: %fr_gb% ГБ >> "%REP%"

echo.
echo [Установленные программы]
echo Идёт сбор информации...
echo. >> "%REP%"
echo [Установленные программы] >> "%REP%"
powershell -NoProfile -Command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object -Property DisplayName | Where-Object {$_.DisplayName -ne $null} | ForEach-Object {$_.DisplayName}" > "%~dp0apps.txt"
type "%~dp0apps.txt"
type "%~dp0apps.txt" >> "%REP%"
del "%~dp0apps.txt"

echo.
echo ====================================
echo Отчёт успешно сохранён в файл pc_report.txt
echo ====================================

pause
