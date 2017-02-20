@echo off
echo Rebuilding 'weapons.iwd'...
    del Release\weapons.iwd
    7z.exe a -r -tzip Release\weapons.iwd ..\raw\weapons
rem Remove placeholders...
    7z.exe d Release\weapons.iwd weapons\mp
Rem ...and rename actual weapon directory.
    7z.exe rn Release\weapons.iwd weapons\rotu_mp weapons\mp
pause
exit 0
