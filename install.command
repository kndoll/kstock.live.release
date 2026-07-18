#!/bin/bash

# K-STOCK LIVE Mac/Linux 실행기

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
echo -e "                        S Y S T E M   L A U N C H E R"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

(docker info >/dev/null 2>&1) &
show_spinner $! "Docker 데스크탑 데몬 확인 중..."
wait $!
if [ $? -ne 0 ]; then
    echo -e " ${RED}[ ✖ ] ERROR: 도커가 실행 중이 아니거나 설치되지 않았습니다.${NC}"
    echo -e "       Docker Desktop을 먼저 실행한 뒤 이 스크립트를 다시 실행해주세요."
    echo ""
    exit 1
fi
echo -e " ${GREEN}✔ Docker 환경 검증 완료.${NC}"
echo ""

cd "$(dirname "$0")"

# K-STOCK 설정 데이터 볼륨 확인 및 환경변수 주입
if ! docker volume ls | grep -q "kstock_config_data"; then
    echo -e " ${CYAN}[ ... ] 최초 설치 감지 - 암호화 볼륨(Volume) 생성 및 설정 중...${NC}"
    POSTGRES_PWD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)
    RABBITMQ_PWD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)
    REDIS_PWD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)
    
    MAC=$(ip link show 2>/dev/null | awk '/ether/{print $2}' | head -n 1)
    if [ -z "$MAC" ]; then MAC=$(ifconfig en0 2>/dev/null | awk '/ether/{print $2}'); fi
    if [ -z "$MAC" ]; then MAC=$(ifconfig eth0 2>/dev/null | awk '/ether/{print $2}'); fi
    if [ -z "$MAC" ]; then MAC="00:00:00:00:00:00"; fi

    printf 'POSTGRES_PASSWORD=%s\nRABBITMQ_PASSWORD=%s\nREDIS_PASSWORD=%s\nHOST_MAC_ADDRESS=%s\n' \
        "$POSTGRES_PWD" "$RABBITMQ_PWD" "$REDIS_PWD" "$MAC" > .env
        
    docker volume create kstock_config_data >/dev/null 2>&1
    docker run --rm -v kstock_config_data:/config -v "$(pwd):/host" alpine cp /host/.env /config/.env >/dev/null 2>&1
    echo -e " ${GREEN}✔ 보안 패스워드 볼륨 저장 완료.${NC}"
    echo ""
else
    echo -e " ${CYAN}[ ... ] 기존 보안 볼륨 발견 - 설정 파일(Env) 복원 중...${NC}"
    docker run --rm -v kstock_config_data:/config -v "$(pwd):/host" alpine cp /config/.env /host/.env >/dev/null 2>&1
fi

(
  docker compose down >/dev/null 2>&1
  docker compose -f docker-compose.release.yml down >/dev/null 2>&1
  docker rm -f kstock-web kstock-app kstock-worker kstock-kafka-ui kstock-rabbitmq kstock-postgres kstock-redis kstock-chromadb kstock-kafka >/dev/null 2>&1
) &
show_spinner $! "기존 K-STOCK LIVE 컨테이너 정리 중 (충돌 방지)..."
wait $!
echo -e " ${GREEN}✔ 이전 컨테이너 정리 완료.${NC}"
echo ""

echo -e " ⏳ K-STOCK LIVE 최신 이미지 다운로드 및 백그라운드 구동..."
docker compose -f docker-compose.release.yml pull
echo ""

echo -e " ⏳ K-STOCK LIVE 인프라 (DB, 메세지 큐 등) 백그라운드 구동 중..."
docker compose -f docker-compose.release.yml up -d
if [ $? -ne 0 ]; then
    echo ""
    echo -e " ${RED}[ ✖ ] ERROR: 컨테이너 실행 중 문제가 발생했습니다. 도커 상태를 확인해주세요.${NC}"
    echo ""
    exit 1
fi
echo -e " ${GREEN}✔ 인프라 구동 완료.${NC}"
echo ""

echo -e "         (시스템 환경에 따라 10~30초 정도 소요될 수 있습니다)"
(
  while ! curl -s -f http://localhost/api/config >/dev/null 2>&1; do
      sleep 3
  done
) &
show_spinner $! "웹 서버 및 워커가 완전히 준비될 때까지 대기 중..."
wait $!
echo -e " ${GREEN}✔ 웹 서버 및 워커 구동 완료.${NC}"
echo ""

  echo -e " ${YELLOW}[ ... ] 백엔드 서버 부팅 대기 중... (최대 30초 소요)${NC}"
  sleep 15
  
  echo -e " ${YELLOW}[ ... ] 최신 한국투자증권(KIS) 종목 마스터 데이터 동기화 중...${NC}"
  for i in {1..6}; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost/api/v1/stocks/sync)
    if [ "$HTTP_STATUS" -eq 200 ]; then
      echo -e " ${GREEN}[  OK ] 종목 데이터 동기화 성공.${NC}"
      break
    else
      echo -e " ${YELLOW}[ ... ] 서버가 아직 준비되지 않았습니다. 5초 후 재시도 ($i/6)...${NC}"
      sleep 5
    fi
  done
  echo ""

IS_DESKTOP=false
if which open >/dev/null; then
    IS_DESKTOP=true
elif which xdg-open >/dev/null && [ -n "$DISPLAY" ]; then
    IS_DESKTOP=true
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} [ IMPORTANT : 최초 실행 시 필수 설정 ]${NC}"
if [ "$IS_DESKTOP" = true ]; then
    echo -e "  잠시 후 브라우저가 열리면 자동으로 [설정] 팝업이 나타납니다."
else
    echo -e "  다른 기기의 브라우저에서 ${GREEN}http://[현재_서버_IP]${NC} 로 접속하시면 [설정] 팝업이 나타납니다."
fi
echo -e "  반드시 API Key (Gemini, 한국투자증권) 정보를 입력해야만 정상 동작합니다."
echo -e "  (이후 설정을 변경하시려면 우측 상단의 톱니바퀴 아이콘을 클릭하세요)"
echo ""
echo -e "  프로그램을 완전히 종료하려면 터미널에서 아래 명령어를 입력하세요:"
echo -e "  docker compose -f docker-compose.release.yml down"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$IS_DESKTOP" = true ]; then
    echo -e " ${GREEN}✔ 모든 점검이 완료되었습니다. 브라우저를 엽니다...${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$IS_DESKTOP" = true ]; then
    echo -e " 💡 터미널 창을 닫아도 시스템은 백그라운드에서 계속 실행됩니다."
else
    echo -e " 💡 현재 터미널(SSH) 접속을 종료하셔도 시스템은 백그라운드에서 계속 실행됩니다."
fi
echo -e "           K-STOCK LIVE는 Docker에서 안전하게 구동 중입니다."
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$IS_DESKTOP" = true ]; then
    if which open >/dev/null; then
        open http://localhost
    else
        xdg-open http://localhost >/dev/null 2>&1
    fi
    echo -e " ${GREEN}✔ 브라우저가 열렸습니다. 이제 이 터미널 창을 닫으셔도 됩니다.${NC}"
fi

# 호스트 환경의 임시 설정 파일 삭제 (무상태 유지)
rm -f .env

exit 0
