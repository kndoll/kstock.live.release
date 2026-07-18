#!/bin/bash

# K-STOCK LIVE Mac/Linux 제거기

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

IS_DESKTOP=false
if which open >/dev/null 2>&1; then
    IS_DESKTOP=true
elif which xdg-open >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
    IS_DESKTOP=true
fi

show_spinner() {
  local pid=$1
  local msg="$2"
  local delay=0.1
  local frames=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
  while kill -0 $pid 2>/dev/null; do
      for frame in "${frames[@]}"; do
          if ! kill -0 $pid 2>/dev/null; then break; fi
          printf "\r \033[0;36m%s\033[0m %s" "$frame" "$msg"
          sleep $delay
      done
  done
  printf "\r\033[K"
}

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
    echo -e " ${GREEN}✔ 제거 작업이 취소되었습니다.${NC}"
    echo ""
    if [ "$IS_DESKTOP" = true ]; then
        echo -e "  [ INFO ] 이제 이 터미널 창을 닫으셔도 됩니다."
        echo ""
    fi
    exit 0
fi

echo ""
(docker info >/dev/null 2>&1) &
show_spinner $! "Docker 데스크탑 데몬 확인 중..."
wait $!
if [ $? -ne 0 ]; then
    echo -e " ${RED}[ ✖ ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.${NC}"
    echo -e "       제거 작업을 위해 Docker Desktop을 실행해주세요."
    echo ""
    exit 1
fi
echo -e " ${GREEN}✔ Docker 환경 검증 완료.${NC}"
echo ""

cd "$(dirname "$0")"

(
  docker compose -f docker-compose.release.yml down -v --rmi all >/dev/null 2>&1
  docker rm -f kstock-web kstock-app kstock-worker kstock-kafka-ui kstock-rabbitmq kstock-postgres kstock-redis kstock-chromadb kstock-kafka >/dev/null 2>&1
  docker volume rm kstock_config_data kstock_postgres_data kstock_kafka_data kstock_chroma_data >/dev/null 2>&1
  docker rmi -f kndoll/kstock-frontend:latest kndoll/kstock-server:latest kndoll/kstock-worker:latest postgres:15-alpine redis:7-alpine rabbitmq:3-management-alpine confluentinc/cp-kafka:7.5.0 chromadb/chroma:0.5.11 >/dev/null 2>&1
) &
show_spinner $! "K-STOCK LIVE 컨테이너, 볼륨, 이미지 제거 중..."
wait $!
rm -f ".env"
echo -e " ${GREEN}✔ 현재 폴더의 컨테이너가 모두 종료 및 제거되었습니다.${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}✔ K-STOCK LIVE가 성공적으로 제거되었습니다.${NC}"
echo -e "         이제 이 설치 경로를 삭제하셔도 됩니다."
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$IS_DESKTOP" = true ]; then
    echo -e " 💡 이제 이 터미널 창을 닫으셔도 됩니다."
    echo ""
fi
exit 0
