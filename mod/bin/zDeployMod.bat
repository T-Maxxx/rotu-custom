@echo off
set MODPATH=D:\Games\CoD4-1.8\mods\rotu_test
echo Copying mod binaries...
    xcopy /Y .\Release %MODPATH%
    del %MODPATH%\dummy