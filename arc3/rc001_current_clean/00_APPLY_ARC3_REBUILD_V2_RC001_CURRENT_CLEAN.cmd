@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if "%~1"=="" goto NOINPUT

set "PY=py -3"
py -3 --version >nul 2>&1
if errorlevel 1 set "PY=python"
%PY% --version >nul 2>&1
if errorlevel 1 goto NOPY

%PY% "%~dp0APPLY_ARC3_REBUILD_V2_RC001_CURRENT_CLEAN.py" "%~1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto FAIL

echo.
echo [PASS] ARC3 RC001 CURRENT-CLEAN PREHW build complete.
echo [INFO] OUTPUT_RC001_CURRENT_CLEAN_PREHW folder의 CUE를 실행하세요.
pause
exit /b 0

:NOINPUT
echo [FAIL] CLEAN ARC3.bin을 이 CMD 위로 드래그하세요.
echo [SHA256] 6f3ec9a3e1193f49376fcae4f54f912dbfac7b773e1dc1c6d6bbe980d1ca124c
pause
exit /b 1

:NOPY
echo [FAIL] Python 3를 찾지 못했습니다.
pause
exit /b 1

:FAIL
echo.
echo [FAIL] 빌드 실패. 위 오류 메시지를 그대로 보내주세요.
pause
exit /b %RC%
