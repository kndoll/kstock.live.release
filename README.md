# K-Stock Live (국내 주식 실시간 대시보드)

<img width="2044" height="1195" alt="스크린샷 2026-06-21 오전 9 33 12" src="https://github.com/user-attachments/assets/d3708e0e-8324-4082-bbab-18765bc14742" />

**K-Stock Live**는 한국투자증권 Open API와 Google Gemini AI를 활용하여 국내 주식 시장의 흐름을 실시간으로 파악하고, AI의 통찰력 있는 브리핑을 받아볼 수 있는 개인용 종합 주식 대시보드입니다.

---

## 핵심 기능 (Key Features)

### 1. 실시간 시장 데이터 (Live Market Data)
* **주요 지수 실시간 모니터링**: 코스피(KOSPI), 코스닥(KOSDAQ), 코스피200 등 핵심 지표 실시간 업데이트
* **다이내믹 마켓 차트**: TradingView 스타일의 직관적이고 부드러운 실시간 시장 차트 제공
* **가격 플래셔(Price Flasher)**: 시세 변동 시 색상 깜빡임 효과를 통해 직관적인 등락 파악

### 2. AI 기반 시장 브리핑 (AI Briefings by Gemini)
* **실시간 시황 요약**: 현재 시장 데이터를 바탕으로 Google Gemini AI가 작성하는 날카로운 시황 브리핑
* **투자 인사이트**: 수급 동향, 핵심 테마, 기술적 지표를 종합적으로 분석한 AI 리포트

### 3. 딥 다이브 분석 도구 (Deep Dive Analytics)
* **투자자별 매매 동향**: 개인, 외국인, 기관의 실시간 수급 현황 파악
* **기술적 지표 분석 (Technical Indicators)**: RSI, MACD, 볼린저 밴드 등 주요 지표 시각화
* **공매도 및 대차잔고 현황**: 시장의 하방 압력을 미리 파악할 수 있는 공매도 데이터
* **주요 ETF 동향**: 레버리지/인버스 및 섹터별 대표 ETF 흐름 추적

### 4. 내 계좌 요약 (Account Summary)
* 실시간 잔고 및 수익률 조회
* 신용잔고 및 예수금 현황 모니터링

### 5. 강력한 편의성 및 보안 (Convenience & Security)
* **사용자 친화적 원클릭 설치**: Docker 기반으로 운영체제(Windows/Mac) 상관없이 스크립트 클릭 한 번에 구동
* **In-App 자동 업데이트**: 번거로운 재설치 없이, 대시보드 설정 창에서 클릭 한 번으로 최신 버전 업데이트 완료
* **강력한 보안 보장**: 사용자의 모든 API 키는 외부 서버로 전송되지 않고 개인의 로컬 PC에만 안전하게 저장

---

## 시작하기 (Getting Started)

K-Stock Live는 누구나 쉽게 설치하고 실행할 수 있도록 패키징되어 있습니다.

1. **사전 준비물**
   * Docker Desktop 설치 및 실행
   * 한국투자증권 API Key & Secret
   * Google Gemini API Key

2. **다운로드 및 설치**
   * 최신 버전 다운로드 및 설치 가이드는 Releases 페이지를 참고해 주세요. (해당 텍스트에 링크 적용 필요)

---

## 기술 스택 (Tech Stack)

* **Frontend**: React, Vite, TailwindCSS, Lucide-React
* **Backend**: Spring Boot 3, Java 21, WebSocket
* **AI & API**: Google Gemini Pro, 한국투자증권 Open API
* **Infrastructure**: Docker, Docker Compose, GitHub Actions

---

## 면책 조항 및 주의사항 (Disclaimer)

* **투자 책임의 소재**: 본 시스템(K-Stock Live)이 제공하는 주가 데이터 및 AI 분석 결과는 단순 참고용입니다. 본 프로그램을 활용한 모든 투자 결정과 매매 결과에 대한 책임은 전적으로 사용자 본인에게 있습니다.
* **상업적 이용 금지**: 본 소프트웨어는 개인적인 투자 참고용으로 제공됩니다. 원저작자의 허가 없이 코드를 무단 복제·재배포하거나, 상업적 목적(유료 리딩방, 상업용 봇 등)으로 이용하는 행위는 엄격히 금지됩니다.
