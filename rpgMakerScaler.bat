@echo off

set path=%~dp0bin\

:Start
ECHO ==========================
ECHO RTP Scaler 0.1 by RyanBram
ECHO ==========================
ECHO Choose scaling method:
ECHO --------------------------
ECHO 1 Smooth (Fast)
ECHO 2 Detailed (Slow)
ECHO --------------------------
rem set /p Method=Method : 

set Method=2

IF %Method%==1 GOTO SmoothScaler
IF %Method%==2 GOTO DetailedScaler

:SmoothScaler
mkdir "%~dp0temp"

"%path%convert.exe" "%~dpn1.png" -filter lanczos -alpha extract "%~dp0temp\mask.png"
"%path%convert.exe" "%~dpn1.png" -filter lanczos -background #808080 -alpha remove "%~dp0temp\%~n1_noalpha.png"

"%path%3xBRLV4.exe" "%~dp0temp\mask.png" "%~dp0temp\mask_Scale3x.png"
"%path%3xBRLV4.exe" "%~dp0temp\%~n1_noalpha.png" "%~dp0temp\%~n1_noalpha_Scale3x.png"

"%path%convert.exe" "%~dp0temp\mask_Scale3x.png" -filter point -resize 50%% "%~dp0temp\mask.bmp"
"%path%convert.exe" "%~dp0temp\%~n1_noalpha_Scale3x.png" -filter point -resize 50%% "%~dp0temp\%~n1_noalpha.bmp"

rem "%path%rotsprite.exe" -in "%~dp0temp\mask_Scale3x.png" -out "%~dp0temp\mask.bmp" -angle 0 -endangle 0 -scale 0.5 -endscale 0.5 -frames 1
rem "%path%rotsprite.exe" -in "%~dp0temp\%~n1_noalpha_Scale3x.png" -out "%~dp0temp\%~n1_noalpha.bmp" -angle 0 -endangle 0 -scale 0.5 -frames 1

"%path%convert.exe" "%~dp0temp\%~n1_noalpha.bmp" "%~dp0temp\mask.bmp" -alpha Off -compose CopyOpacity -composite "%~dpn1_PixelScaled.png"

GOTO Cleanup

:DetailedScaler
mkdir "%~dp0temp"

"%path%convert.exe" "%~dpn1.png" -filter lanczos -alpha extract "%~dp0temp\mask.png"
"%path%convert.exe" "%~dpn1.png" -filter lanczos -background #808080 -alpha remove "%~dp0temp\%~n1_noalpha.png"

"%path%3xBRLV4.exe" "%~dp0temp\mask.png" "%~dp0temp\mask_Scale3x.png"

"%path%waifu2x-converter" -i "%~dp0temp\%~n1_noalpha.png" -m scale --scale_ratio 1.5 --noise_level 1 --model_dir "%path%models" -o "%~dp0temp\%~n1_noalpha_Waifu2x.png"
"%path%convert.exe" "%~dp0temp\mask_Scale3x.png" -filter point -resize 50%% "%~dp0temp\mask.bmp"

"%path%convert.exe" "%~dp0temp\%~n1_noalpha_Waifu2x.png" "%~dp0temp\mask.bmp" -alpha Off -compose CopyOpacity -composite +dither -remap "%~dpn1.png" "%~dpn1_Waifu2xScaled1.png"
"%path%convert.exe" "%~dp0temp\%~n1_noalpha_Waifu2x.png" "%~dp0temp\mask.bmp" -alpha Off -compose CopyOpacity -composite png:- | "%path%pngquant.exe" --verbose --speed 1 --nofs 256 - | "%path%convert.exe" png:- "%~dpn1_Waifu2xScaled2.png"
"%path%convert.exe" "%~dp0temp\%~n1_noalpha_Waifu2x.png" "%~dp0temp\mask.bmp" -alpha Off -compose CopyOpacity -composite "%~dpn1_Waifu2xScaled3.png"

GOTO Cleanup

:Cleanup
rmdir /s /q "%~dp0temp"
rem del "%~dp0\temp%~n1_Scale3x.png"
rem del "%~dp0\temp%~n1_noalpha.png"
rem del "%~dp0temp\mask.png"
rem del "%~dp0\temp%~n1_noalpha.bmp"
rem del "%~dp0temp\mask.bmp"

rem shift
rem if NOT x%1==x goto Start

rem pause