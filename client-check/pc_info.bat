@echo off
chcp 65001 > nul

REM =========================================================
REM Тема: Инструментальные средства ревьюирования, проверки на стороне клиента.
REM Автор: [Карпов]
REM Дата: 30.10.2026
REM =========================================================

set "REPORT_FILE=%~dp0pc_report.txt"

REM Очищаем файл отчёта перед началом работы, если он существовал
echo Диагностика компьютера > "%REPORT_FILE%"
echo ==================================== >> "%REPORT_FILE%"

echo Диагностика компьютера
echo ====================================

REM --- СВЕДЕНИЯ ОБ ОПЕРАЦИОННОЙ СИСТЕМЕ ---
echo.
echo [Операционная система]
echo. >> "%REPORT_FILE%"
echo [Операционная система] >> "%REPORT_FILE%"

for /f "tokens=*" %%i in ('wmic os get Caption^,Version /format:list ^| findstr "="') do (
    echo %%i
    echo %%i >> "%REPORT_FILE%"
)

REM --- СВЕДЕНИЯ О ПРОЦЕССОРЕ ---
echo.
echo [Процессор]
echo. >> "%REPORT_FILE%"
echo [Процессор] >> "%REPORT_FILE%"

for /f "tokens=*" %%i in ('wmic cpu get Name /format:list ^| findstr "="') do (
    echo %%i
    echo %%i >> "%REPORT_FILE%"
)

REM --- СВЕДЕНИЯ ОБ ОПЕРАТИВНОЙ ПАМЯТИ ---
echo.
echo [Оперативная память]
echo. >> "%REPORT_FILE%"
echo [Оперативная память] >> "%REPORT_FILE%"

for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /format:list ^| findstr "="') do set /a "TotalMem=%%i / 1048576"
for /f "tokens=2 delims==" %%i in ('wmic os get FreePhysicalMemory /format:list ^| findstr "="') do set /a "FreeMem=%%i / 1048576"

echo Всего памяти: %TotalMem% ГБ
echo Всего памяти: %TotalMem% ГБ >> "%REPORT_FILE%"
echo Свободно памяти: %FreeMem% ГБ
echo Свободно памяти: %FreeMem% ГБ >> "%REPORT_FILE%"

REM --- СВОБОДНОЕ МЕСТО НА ДИСКЕ ---
echo.
echo [Диск C]
echo. >> "%REPORT_FILE%"
echo [Диск C] >> "%REPORT_FILE%"

for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where DeviceID^="C:" get Size /format:list ^| findstr "="') do set /a "DiskSize=%%i / 1073741824"
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where DeviceID^="C:" get FreeSpace /format:list ^| findstr "="') do set /a "DiskFree=%%i / 1073741824"

echo Общий размер диска C: %DiskSize% ГБ
echo Общий размер диска C: %DiskSize% ГБ >> "%REPORT_FILE%"
echo Свободно на диске C: %DiskFree% ГБ
echo Свободно на диске C: %DiskFree% ГБ >> "%REPORT_FILE%"

REM --- СПИСОК УСТАНОВЛЕННЫХ ПРОГРАММ ---
echo.
echo [Установленные программы]
echo Идёт сбор информации о программах...
echo. >> "%REPORT_FILE%"
echo [Установленные программы] >> "%REPORT_FILE%"

for /f "tokens=2,*" %%a in ('reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall /s /f DisplayName ^| findstr "DisplayName"') do (
    echo %%b
    echo %%b >> "%REPORT_FILE%"
)
for /f "tokens=2,*" %%a in ('reg query HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s /f DisplayName ^| findstr "DisplayName"') do (
    echo %%b
    echo %%b >> "%REPORT_FILE%"
)

REM --- ЗАВЕРШЕНИЕ РАБОТЫ ---
echo.
echo ====================================
echo Отчёт успешно сохранён в файл pc_report.txt
echo ====================================

pause
