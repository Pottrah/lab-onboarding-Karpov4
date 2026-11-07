@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Установка путей к файлам
set "report_file=%~dp0pc_report.txt"
set "temp_apps=%temp%\apps_list.txt"

:: Очистка старого отчета перед стартом
if exist "%report_file%" del "%report_file%"

echo === Запуск аудита системы ===
echo Выполняется сбор данных, пожалуйста, подождите...
echo.

:: ==========================================
:: НАЧАЛО ОТЧЕТА И ВРЕМЕННАЯ МЕТКА
:: ==========================================
call :log "===================================================="
call :log "          ОТЧЕТ ОБ АУДИТЕ КОМПЬЮТЕРА                "
call :log "===================================================="
for /f "tokens=1-3 delims=. " %%a in ("%date%") do set "mydate=%%c-%%b-%%a"
call :log "Дата и время проверки: %mydate% %time%"
call :log "----------------------------------------------------"

:: ==========================================
:: ШАГ 3. СБОР И ЗАЩИТА ОТ ПУСТЫХ ЗНАЧЕНИЙ
:: ==========================================
call :log "[1. Общие сведения о системе]"

:: Очищаем переменные перед использованием
set "os_name="
set "total_ram="

:: Сбор данных через PowerShell (устойчиво к отсутствию wmic в Win 11)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do set "os_name=%%i"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "[math]::round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)"`) do set "total_ram=%%i"

:: Проверка на пустые значения
if not defined os_name (
    call :log "Операционная система: Не удалось получить данные"
) else (
    call :log "Операционная система: %os_name%"
)

if not defined total_ram (
    call :log "Оперативная память: Не удалось получить данные"
) else (
    call :log "Оперативная память: %total_ram% ГБ"
)
call :log " "

:: ==========================================
:: ШАГ 4. ФОРМИРОВАНИЕ ЕДИНОГО СПИСКА ПРОГРАММ
:: ==========================================
echo [Процесс] Сканирование установленного ПО в реестре...
if exist "%temp_apps%" del "%temp_apps%"

:: Опрос 64-битной ветки реестра
for /f "usebackq tokens=2 master delims=	 " %%A in (`reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul`) do (
    set "app_name=%%A"
    if not "!app_name!"=="" echo !app_name! >> "%temp_apps%"
)

:: Опрос 32-битной ветки реестра (WOW6432Node)
for /f "usebackq tokens=2 master delims=	 " %%A in (`reg query "HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul`) do (
    set "app_name=%%A"
    if not "!app_name!"=="" echo !app_name! >> "%temp_apps%"
)

:: ==========================================
:: ШАГ 5. РАЗДЕЛ РЕКОМЕНДАЦИЙ ПО НЕДОСТАЮЩЕМУ ПО
:: ==========================================
call :log "[2. Анализ базового офисного ПО]"
set /a missing_count=0
set /a checked_categories=0

:: 1. Офисный пакет
set "found_office="
set /a checked_categories+=1
findstr /I /C:"Office" /C:"LibreOffice" /C:"OpenOffice" /C:"МойОфис" "%temp_apps%" >nul
if %errorlevel%==0 (
    call :log "[ OK ] Офисный пакет: Установлен"
) else (
    call :log "[ВНИМАНИЕ] Не обнаружен офисный пакет. Рекомендуется установить LibreOffice или МойОфис для работы с документами."
    set /a missing_count+=1
)

:: 2. Архиватор
set /a checked_categories+=1
findstr /I /C:"7-Zip" /C:"WinRAR" /C:"WinZip" "%temp_apps%" >nul
if %errorlevel%==0 (
    call :log "[ OK ] Архиватор: Установлен"
) else (
    call :log "[ВНИМАНИЕ] Не обнаружен архиватор. Для работы с вложениями в почте рекомендуется установить 7-Zip."
    set /a missing_count+=1
)

:: 3. Программа PDF
set /a checked_categories+=1
findstr /I /C:"Acrobat" /C:"Foxit" /C:"SumatraPDF" "%temp_apps%" >nul
if %errorlevel%==0 (
    call :log "[ OK ] Программа PDF: Установлена"
) else (
    call :log "[ВНИМАНИЕ] Не обнаружена программа чтения PDF. Рекомендуется установить Foxit Reader или SumatraPDF."
    set /a missing_count+=1
)

:: 4. Браузер (Проверка сторонних, Edge считаем системным)
set /a checked_categories+=1
findstr /I /C:"Chrome" /C:"Firefox" /C:"Яндекс" /C:"Yandex" "%temp_apps%" >nul
if %errorlevel%==0 (
    call :log "[ OK ] Дополнительный рабочий браузер: Установлен"
) else (
    call :log "[ИНФО] Сторонние браузеры не найдены. Используется встроенный Microsoft Edge (компонент системы)."
)
call :log " "

:: ==========================================
:: ШАГ 6. РАЗДЕЛ РЕКОМЕНДАЦИЙ ПО ИЗЛИШНЕМУ ПО
:: ==========================================
call :log "[3. Анализ нецелевого и избыточного ПО]"
call :log "Примечание: Вывод является рекомендацией. Решение об удалении принимает администратор."
set /a Recommendations_issued=0

:: Группа 1: Игры
call :log "--- Проверка игрового ПО ---"
set "game_found=0"
for %%G in (Steam "Epic Games" GOG Origin "Ubisoft Connect" Battle.net Riot game gaming) do (
    findstr /I /C:%%G "%temp_apps%" >nul
    if !errorlevel!==0 (
        call :log "[НА ПРОВЕРКУ] Обнаружены следы игрового ПО по критерию: %%G"
        set "game_found=1"
    )
)
if "!game_found!"=="0" call :log "Игровое ПО не обнаружено."

:: Группа 2: Торренты
call :log "--- Проверка торрент-клиентов ---"
set "torrent_found=0"
for %%T in (torrent uTorrent BitTorrent qBittorrent Vuze) do (
    findstr /I /C:%%T "%temp_apps%" >nul
    if !errorlevel!==0 (
        call :log "[НА ПРОВЕРКУ] Обнаружен файлообменный клиент: %%T. Создает нагрузку на сеть."
        set "torrent_found=1"
        set /a Recommendations_issued+=1
    )
)
if "!torrent_found!"=="0" call :log "Торрент-клиенты не обнаружены."

:: Группа 3: Нестандартные мессенджеры
call :log "--- Проверка приложений для личного общения ---"
set "msg_found=0"
for %%M in (Discord Telegram WhatsApp Viber Skype) do (
    findstr /I /C:%%M "%temp_apps%" >nul
    if !errorlevel!==0 (
        call :log "[НА ПРОВЕРКУ] Найден мессенджер %%M. Проверьте соответствие корпоративному стандарту."
        set "msg_found=1"
    )
)
if "!msg_found!"=="0" call :log "Сторонние мессенджеры не обнаружены."

:: Группа 4: Инструменты развлечения
call :log "--- Проверка мультимедиа ПО для развлечений ---"
set "media_found=0"
for %%E in ("Wallpaper Engine" OBS Soundpad) do (
    findstr /I /C:%%E "%temp_apps%" >nul
    if !errorlevel!==0 (
        call :log "[НА ПРОВЕРКУ] Найдено ПО для развлечений/стриминга: %%E."
        set "media_found=1"
        set /a Recommendations_issued+=1
    )
)
if "!media_found!"=="0" call :log "Избыточное развлекательное ПО не обнаружено."
call :log " "

:: ==========================================
:: ШАГ 7. ЗАВЕРШЕНИЕ РАБОТЫ И ИТОГИ
:: ==========================================
set /a total_rec = missing_count + Recommendations_issued
call :log "===================================================="
call :log "ИТОГ АУДИТА:"
call :log "Категорий базового ПО проверено: %checked_categories%"
call :log "Выдано рекомендаций к действию: %total_rec%"
call :log "Полный путь к отчету: %report_file%"
call :log "===================================================="

:: Удаляем временный файл списка программ
if exist "%temp_apps%" del "%temp_apps%"

echo.
echo Аудит успешно завершен.
pause
exit /b

:: ==========================================
:: ШАГ 2. ПОДПРОГРАММА ВЫВОДА (ЛОГИРОВАНИЕ)
:: ==========================================
:log
:: Используем открывающую скобку для корректного вывода пустых строк
if "%~1"==" " (
    echo(
    echo(>> "%report_file%"
) else (
    echo(%~1
    echo(%~1>> "%report_file%"
)
exit /b
