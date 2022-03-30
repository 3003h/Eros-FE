@echo off

flutter build windows --release

set DestDir=build\windows\runner\fehviewer
set SrcDir=build\windows\runner\Release

if exist %DestDir%\ (
    echo %DestDir% exist
    del /f /q %DestDir%
) else (
    echo mkdir %DestDir%
    md %DestDir%
)
::rd /s /q %DestDir%

xcopy /e /h /q /y %SrcDir% %DestDir%
xcopy /y windows\*.dll %SrcDir%\*