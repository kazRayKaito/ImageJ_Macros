@echo off
setlocal enabledelayedexpansion

:: Get the current date in a reliable format (YYYYMMDD)
for /f "tokens=1-3" %%a in ('wmic path win32_localtime get day^,month^,year /format:table ^| findstr "^[0-9]"') do (
    set "currentDate=%%c%%b%%a"
)

:: Calculate the year and month 6 months ago
set /a "year=!currentDate:~0,4!"
set /a "month=!currentDate:~4,2!"

if %month% LSS 7 (
    set /a "year-=1"
    set /a "month+=6"
) else (
    set /a "month-=6"
)

:: Ensure month is zero-padded to two digits
if %month% lss 10 (
    set "month=0%month%"
)

:: Print the result in YYYYMM format
echo The date 6 months ago was: !year!!month!

endlocal
pause