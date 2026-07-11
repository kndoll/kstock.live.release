@echo off
chcp 65001 >nul
goto :init_encoding
:init_encoding
title K-STOCK LIVE Uninstaller

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   _  __       _____ _______ ____   _____ _  __   _      _____      ________ 
echo  ^| ^|/ /      / ____^|__   __/ __ \ / ____^| ^|/ /  ^| ^|    ^|_   _\ \    / /  ____^|
echo  ^| ' /______^| (___    ^| ^| ^| ^|  ^| ^| ^|    ^| ' /   ^| ^|      ^| ^|  \ \  / /^| ^|__   
echo  ^|  ^<______^| \___ \   ^| ^| ^| ^|  ^| ^| ^|    ^|  ^<    ^| ^|      ^| ^|   \ \/ / ^|  __^|  
echo  ^| . \       ____) ^|  ^| ^| ^| ^|__^| ^| ^|____^| . \   ^| ^|____ _^| ^|_   \  /  ^| ^|____ 
echo  ^|_^|\_\     ^|_____/   ^|_^|  \____/ \_____^|_^|\_\  ^|______^|_____^|   \/   ^|______^|
echo.
echo                       S Y S T E M   U N I N S T A L L E R
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  [ WARNING ] 이 작업은 K-STOCK LIVE를 시스템에서 완전히 제거합니다.
echo              모든 도커 컨테이너, 다운로드된 이미지, 그리고 데이터베이스
echo              (API Key 및 관심 종목 포함)가 영구적으로 삭제됩니다.
echo.
set /p AREYOUSURE="  정말 진행하시겠습니까? (Y/N): "
if /i "%AREYOUSURE%" neq "Y" (
    echo.
    echo  [  OK ] 제거 작업이 취소되었습니다.
    echo.
    echo  [ INFO ] 이제 이 명령 프롬프트 창을 닫으셔도 됩니다.
    pause
    exit /b 0
)

echo.
echo  [ ... ] Docker 데스크탑 데몬 확인 중...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ ? ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.
    echo        제거 작업을 위해 Docker Desktop을 실행해주세요.
    echo.
    pause
    exit /b 1
)
echo  [  OK ] Docker 환경 검증 완료.
echo.

echo  [ ... ] K-STOCK LIVE 컨테이너, 볼륨, 이미지 제거 중...
docker compose -f docker-compose.release.yml down -v --rmi all
if exist ".env" del /f /q ".env"
echo  [  OK ] 현재 폴더의 컨테이너가 모두 종료 및 제거되었습니다.
echo          (단, 다른 경로에서 실행 중인 K-STOCK 컨테이너가 있다면 공용 이미지/볼륨은 보존됩니다.)
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  [  OK ] K-STOCK LIVE가 성공적으로 제거되었습니다.
echo          이제 이 폴더를 안전하게 삭제하셔도 됩니다.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  [OK] 이제 이 명령 프롬프트 창을 닫으셔도 됩니다.
echo.
pause
exit /b 0
