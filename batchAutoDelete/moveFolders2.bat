@echo off
setlocal enabledelayedexpansion

set "sourcePath=C:\Users\Kazuk\Documents\2_Projects\Batch\moveFolderTsTm\source"
set "destinationPath=C:\Users\Kazuk\Documents\2_Projects\Batch\moveFolderTsTm\dest"
set "cutoffDate="
for /f "delims=" %%a in ('powershell -command "(Get-Date).AddMonths(-6).ToString('yyyy-MM-dd')"') do set cutoffDate=%%a

for /d %%D in ("%sourcePath%\*") do (
    set folderName=%%~nxD
    set folderDate=!folderName:~0,10!
    
    rem Convert folderDate to a sortable format (yyyy-MM-dd)
    for /f "tokens=1-3 delims=/" %%A in ("!folderDate!") do (
        set "sortedFolderDate=%%C-%%A-%%B"
    )

    if "!sortedFolderDate!" leq "%cutoffDate%" (
        echo Moving "%%D" to "%destinationPath%"
        move "%%D" "%destinationPath%"
    )
)

endlocal
pause