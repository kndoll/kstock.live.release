#!/bin/bash

# K-Stock Live Mac/Linux 실행기

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "   _  __       _____ _______ ____   _____ _  __   _      _____      ________ "
echo -e "  | |/ /      / ____|__   __/ __ \ / ____| |/ /  | |    |_   _\ \    / /  ____|"
echo -e "  | ' /______| (___    | | | |  | | |    | ' /   | |      | |  \ \  / /| |__   "
echo -e "  |  <______| \___ \   | | | |  | | |    |  <    | |      | |   \ \/ / |  __|  "
echo -e "  | . \       ____) |  | | | |__| | |____| . \   | |____ _| |_   \  /  | |____ "
echo -e "  |_|\_\     |_____/   |_|  \____/ \_____|_|\_\  |______|_____|   \/   |______|"
echo ""
echo -e "                        S Y S T E M   L A U N C H E R"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e " [ ... ] Docker 데스크탑 데몬 확인 중..."
if ! docker info >/dev/null 2>&1; then
    echo -e " ${RED}[ ✖ ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.${NC}"
    echo -e "       Docker Desktop을 먼저 실행한 뒤 이 스크립트를 다시 실행해주세요."
    echo ""
    exit 1
fi
echo -e " ${GREEN}[  OK ] Docker 환경 검증 완료.${NC}"
echo ""

cd "$(dirname "$0")"

echo -e " [ ... ] 기존 K-STOCK LIVE 컨테이너 정리 중 (충돌 방지)..."
docker compose down >/dev/null 2>&1
docker compose -f docker-compose.release.yml down >/dev/null 2>&1
docker rm -f kstock-web kstock-app kstock-worker kstock-kafka-ui kstock-rabbitmq kstock-postgres kstock-redis kstock-chromadb kstock-kafka >/dev/null 2>&1
echo -e " ${GREEN}[  OK ] 이전 컨테이너 정리 완료.${NC}"
echo ""

echo -e " [ ... ] K-STOCK LIVE 최신 이미지 풀링 및 백그라운드 구동..."
docker compose -f docker-compose.release.yml pull >/dev/null 2>&1
docker compose -f docker-compose.release.yml up -d
if [ $? -ne 0 ]; then
    echo ""
    echo -e " ${RED}[ ✖ ] ERROR: 컨테이너 실행 중 문제가 발생했습니다. 도커 상태를 확인해주세요.${NC}"
    echo ""
    exit 1
fi
echo -e " ${GREEN}[  OK ] K-STOCK LIVE 인프라 구동 성공.${NC}"
echo ""

echo -e " [ ... ] 웹 서버 및 워커가 완전히 준비될 때까지 대기 중..."
echo -e "         (시스템 환경에 따라 10~30초 정도 소요될 수 있습니다)"
while ! curl -s -f http://localhost/api/config >/dev/null 2>&1; do
    sleep 3
done
echo -e " ${GREEN}[  OK ] 웹 서버 및 워커 구동 완료.${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} [ IMPORTANT : 최초 실행 시 필수 설정 ]${NC}"
echo -e "  K-STOCK LIVE 앱에 접속하신 후 우측 상단의 톱니바퀴 아이콘(설정)을 클릭하여"
echo -e "  반드시 API Key (Gemini, 한국투자증권) 설정을 완료해주셔야 정상 동작합니다."
echo ""
echo -e "  종료하려면 터미널에서 아래 명령어를 입력하세요:"
echo -e "  docker compose -f docker-compose.release.yml down"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e " ${GREEN}[  OK ] 모든 점검이 완료되었습니다. 브라우저를 엽니다...${NC}"

if which open >/dev/null; then
    open http://localhost
elif which xdg-open >/dev/null; then
    xdg-open http://localhost
fi
