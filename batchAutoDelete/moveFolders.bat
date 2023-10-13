@echo off
setlocal enabledelayedexpansion

set "sourcePath=C:\Users\Kazuk\Documents\2_Projects\Batch\moveFolderTsTm\dest"
set "destinationPath=C:\Users\Kazuk\Documents\2_Projects\Batch\moveFolderTsTm\source"
set "cutoffDate="
for /f "delims=" %%a in ('powershell -command "(Get-Date).AddMonths(-6).ToString('yyyyMMdd')"') do set cutoffDate=%%a

for /d %%D in ("%sourcePath%\*") do (
    set folderName=%%~nxD
    if !folderName! leq %cutoffDate% (
        echo Moving "%%D" to "%destinationPath%"
        move "%%D" "%destinationPath%"
    )
)

endlocal

pause