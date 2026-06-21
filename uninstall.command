#!/bin/bash

# K-Stock Live Mac/Linux 제거기

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
echo -e "                       S Y S T E M   U N I N S T A L L E R"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW} [ WARNING ] 이 작업은 K-STOCK LIVE를 시스템에서 완전히 제거합니다.${NC}"
echo -e "             모든 도커 컨테이너, 다운로드된 이미지, 그리고 데이터베이스"
echo -e "             (API Key 및 관심 종목 포함)가 영구적으로 삭제됩니다."
echo ""
read -p "  정말 진행하시겠습니까? (Y/N): " AREYOUSURE

if [[ "$AREYOUSURE" != "Y" && "$AREYOUSURE" != "y" ]]; then
    echo ""
    echo -e " ${GREEN}[  OK ] 제거 작업이 취소되었습니다.${NC}"
    exit 0
fi

echo ""
echo -e " [ ... ] Docker 데스크탑 데몬 확인 중..."
if ! docker info >/dev/null 2>&1; then
    echo -e " ${RED}[ ✖ ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.${NC}"
    echo -e "       제거 작업을 위해 Docker Desktop을 실행해주세요."
    echo ""
    exit 1
fi
echo -e " ${GREEN}[  OK ] Docker 환경 검증 완료.${NC}"
echo ""

cd "$(dirname "$0")"

echo -e " [ ... ] K-STOCK LIVE 컨테이너, 볼륨, 이미지 제거 중..."
docker compose -f docker-compose.release.yml down -v --rmi all
echo -e " ${GREEN}[  OK ] 모든 컨테이너와 이미지가 제거되었습니다.${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}[  OK ] K-STOCK LIVE가 성공적으로 제거되었습니다.${NC}"
echo -e "         이제 이 폴더를 안전하게 삭제하셔도 됩니다."
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e " 💡 이 창은 5초 뒤 자동으로 닫힙니다."
echo ""

sleep 5
osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1
exit 0
