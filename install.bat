@echo off
chcp 65001 >nul
title K-STOCK LIVE Launcher

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   _  __       _____ _______ ____   _____ _  __   _      _____      ________ 
echo  ^| ^|/ /      / ____^|__   __/ __ \ / ____^| ^|/ /  ^| ^|    ^|_   _\ \    / /  ____^|
echo  ^| ' /______^| (___    ^| ^| ^| ^|  ^| ^| ^|    ^| ' /   ^| ^|      ^| ^|  \ \  / /^| ^|__   
echo  ^|  ^<______^| \___ \   ^| ^| ^| ^|  ^| ^| ^|    ^|  ^<    ^| ^|      ^| ^|   \ \/ / ^|  __^|  
echo  ^| . \       ____) ^|  ^| ^| ^| ^|__^| ^| ^|____^| . \   ^| ^|____ _^| ^|_   \  /  ^| ^|____ 
echo  ^|_^|\_\     ^|_____/   ^|_^|  \____/ \_____^|_^|\_\  ^|______^|_____^|   \/   ^|______^|
echo.
echo                        S Y S T E M   L A U N C H E R
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  [ ... ] Docker 데스크탑 데몬 확인 중...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ ? ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.
    echo        Docker Desktop을 먼저 실행한 뒤 다시 시도해주세요.
    echo.
    pause
    exit /b 1
)
echo  [  OK ] Docker 환경 검증 완료.
echo.

if exist ".env" goto SKIP_ENV
echo  [ ... ] 최초 설치 감지 - 보안 패스워드 자동 생성 중...
powershell -NoProfile -Command "$p=[guid]::NewGuid().ToString().Replace('-','').Substring(0,24); Add-Content -Path '.env' -Value ('POSTGRES_PASSWORD='+$p)"
powershell -NoProfile -Command "$r=[guid]::NewGuid().ToString().Replace('-','').Substring(0,24); Add-Content -Path '.env' -Value ('RABBITMQ_PASSWORD='+$r)"
powershell -NoProfile -Command "$d=[guid]::NewGuid().ToString().Replace('-','').Substring(0,24); Add-Content -Path '.env' -Value ('REDIS_PASSWORD='+$d)"
echo  [  OK ] 보안 패스워드 생성 완료.
echo.
:SKIP_ENV

echo  [ ... ] 기존 K-STOCK LIVE 컨테이너 정리 중 (충돌 방지)...
docker compose down >nul 2>&1
docker compose -f docker-compose.release.yml down >nul 2>&1
docker rm -f kstock-web kstock-app kstock-worker kstock-kafka-ui kstock-rabbitmq kstock-postgres kstock-redis kstock-chromadb kstock-kafka >nul 2>&1
echo  [  OK ] 이전 컨테이너 정리 완료.
echo.

echo  [ ... ] K-STOCK LIVE 최신 이미지 다운로드 및 백그라운드 구동...
docker compose -f docker-compose.release.yml pull
echo.

echo  [ ... ] K-STOCK LIVE 인프라 (DB, 메세지 큐 등) 백그라운드 구동 중...
docker compose -f docker-compose.release.yml up -d
if %errorlevel% neq 0 (
    echo.
    echo  [ ? ] ERROR: 컨테이너 실행 중 문제가 발생했습니다. 도커 상태를 확인해주세요.
    echo.
    pause
    exit /b 1
)
echo  [  OK ] 인프라 구동 완료.
echo.

echo  [ ... ] 웹 서버 및 워커가 완전히 준비될 때까지 대기 중... 
echo          (시스템 환경에 따라 10~30초 정도 소요될 수 있습니다)
:WAIT_LOOP
curl.exe -s -f http://localhost/api/config >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 3 >nul
    goto WAIT_LOOP
)
echo  [  OK ] 웹 서버 및 워커 구동 완료.
echo.

echo  [ ... ] 최신 한국투자증권(KIS) 종목 마스터 데이터 동기화 중...
curl.exe -X POST http://localhost/api/v1/stocks/sync >nul 2>&1
echo  [  OK ] 종목 데이터 동기화 완료.
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  [ IMPORTANT : 최초 실행 시 필수 설정 ]
echo  브라우저에 앱이 열리면 자동으로 [설정] 팝업이 나타납니다.
echo  반드시 API Key (Gemini, 한국투자증권) 정보를 입력해야만 정상 동작합니다.
echo  (이후 설정을 변경하시려면 우측 상단의 톱니바퀴 아이콘을 클릭하세요)
echo.
echo  프로그램을 완전히 종료하려면 터미널에서 아래 명령어를 입력하세요:
echo  docker compose -f docker-compose.release.yml down
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  [  OK ] 모든 점검이 완료되었습니다. 브라우저를 엽니다...
start http://localhost
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  [OK] 이 창은 5초 뒤 자동으로 닫힙니다.
echo      K-STOCK LIVE는 Docker에서 백그라운드로 계속 실행됩니다.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
timeout /t 5 >nul
exit
