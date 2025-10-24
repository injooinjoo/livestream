# OBS Helper - 스트리밍 도우미 서비스 설계 문서

## 1. 프로젝트 개요

### 1.1 목적
OBS/XSplit과 연동하여 스트리머들이 방송을 효율적으로 관리할 수 있도록 돕는 **웹 네이티브 오버레이 플랫폼**

### 1.2 핵심 설계 철학 (위플랩 기반)

#### "URL을 애플리케이션으로"
- 별도의 프로그램 설치 불필요
- 브라우저 소스에 URL만 추가하면 즉시 작동
- 서버 측 업데이트로 즉시 모든 사용자에게 반영

#### "경량화와 안정성"
- 낮은 CPU 사용률 (게임 + 방송에 영향 없음)
- 공식 API 사용으로 안정성 확보
- 무거운 로컬 애플리케이션 대신 클라우드 기반

#### "신속한 반복 개발"
- 사용자 피드백을 빠르게 반영
- 웹 기반으로 즉시 배포 가능
- 플랫폼 독립적 (Windows, Mac, Linux)

### 1.3 주요 타겟
- 개인 스트리머 (초보 ~ 중급)
- 듀얼 PC 없이 단일 PC로 방송하는 스트리머
- 한국 플랫폼 사용자 (SOOP, 치지직 우선)

### 1.4 벤치마크 분석

| 특성 | 위플랩 | StreamElements | Streamlabs | **우리 서비스** |
|------|--------|----------------|------------|----------------|
| 설치 방식 | 웹 (URL) | 웹 (URL) | 데스크톱 앱 | **웹 (URL)** |
| CPU 사용 | 낮음 | 낮음 | 높음 | **낮음** |
| 업데이트 | 자동 | 자동 | 수동 | **자동** |
| 주요 시장 | 한국 | 글로벌 | 글로벌 | **한국 + 확장** |
| 커스터마이징 | CSS | CSS/HTML/JS | 제한적 | **CSS + JSON** |
| 오픈소스 | X | X | X | **O** |

## 2. 핵심 기능 요구사항

### 2.1 필수 기능 (MVP)

#### 2.1.1 브라우저 소스 위젯
- **알림 위젯**: 팔로우, 구독, 후원 알림
- **채팅 오버레이**: 실시간 채팅 표시
- **시청자 카운터**: 현재 시청자 수 표시
- **최근 팔로워/구독자**: 최근 활동 표시

#### 2.1.2 플랫폼 연동
- Twitch API 연동
- YouTube Live API 연동
- AfreecaTV API 연동 (향후)

#### 2.1.3 대시보드
- 위젯 설정 및 커스터마이징
- 위젯 URL 생성 및 관리
- 실시간 방송 통계 확인
- 알림 히스토리

#### 2.1.4 인증 및 사용자 관리
- OAuth 2.0 기반 소셜 로그인
- 사용자 프로필 관리
- 플랫폼 계정 연동

### 2.2 부가 기능 (Phase 2)

#### 2.2.1 고급 위젯
- **미디어 공유**: 시청자가 공유한 미디어 재생
- **투표/설문**: 실시간 투표 시스템
- **목표 게이지**: 구독자/후원 목표 진행률
- **최근 이벤트**: 활동 로그 표시

#### 2.2.2 채팅봇
- 자동 응답 메시지
- 커스텀 명령어
- 채팅 필터링 및 모더레이션

#### 2.2.3 분석 및 통계
- 시청자 추세 분석
- 수익 통계
- 성장 리포트

#### 2.2.4 모바일 앱
- 실시간 방송 모니터링
- 푸시 알림
- 긴급 공지 발송

## 3. 시스템 아키텍처

### 3.1 핵심 데이터 흐름 (위플랩 방식)

```
[1. 플랫폼 이벤트 발생]
     Twitch: 새 팔로워
          ↓

[2. 플랫폼 API → 백엔드]
     EventSub WebHook
     또는 API Polling
          ↓

[3. 백엔드 이벤트 처리]
     - 사용자 확인
     - 위젯 설정 로드
     - 이벤트 가공
          ↓

[4. WebSocket 실시간 푸시]
     Socket.IO Room
     (widgetId별 채널)
          ↓

[5. OBS 브라우저 소스]
     - 이벤트 수신
     - 애니메이션 실행
     - 사운드 재생
          ↓

[6. 방송 화면에 표시]
     OBS가 캡처하여
     최종 스트림에 합성
```

### 3.2 전체 시스템 구조

```
┌──────────────────────────────────────────────────────┐
│                   스트리머 환경                        │
│                                                       │
│  ┌─────────────────┐      ┌─────────────────┐       │
│  │  OBS/XSplit     │      │  웹 브라우저      │       │
│  │                 │      │  (대시보드)       │       │
│  │  ┌───────────┐  │      │                 │       │
│  │  │브라우저소스│◄─┼──────┼─► 위젯 설정     │       │
│  │  │ (위젯URL) │  │  WS  │   테스트 전송   │       │
│  │  └───────────┘  │      └────────┬────────┘       │
│  └─────────────────┘               │                │
└───────────────────────────────────┼────────────────┘
                                    │ HTTPS
                 ┌──────────────────┴──────────────────┐
                 │                                      │
        ┌────────▼────────┐              ┌─────────────▼──────┐
        │   API Server    │              │  WebSocket Server  │
        │   (NestJS)      │◄────────────►│   (Socket.IO)      │
        │                 │   Redis      │                    │
        │ - REST API      │   Adapter    │ - Room 기반        │
        │ - OAuth         │              │ - 실시간 이벤트    │
        │ - 위젯 관리     │              │ - 수평 확장 가능   │
        └────────┬────────┘              └──────────┬─────────┘
                 │                                   │
                 │        ┌──────────────────────────┘
                 │        │
        ┌────────▼────────▼────────┐
        │    데이터 레이어          │
        │                          │
        │  ┌──────────────────┐   │
        │  │   PostgreSQL     │   │
        │  │ - Users          │   │
        │  │ - Widgets        │   │
        │  │ - Events         │   │
        │  └──────────────────┘   │
        │                          │
        │  ┌──────────────────┐   │
        │  │     Redis        │   │
        │  │ - Sessions       │   │
        │  │ - WebSocket연결  │   │
        │  │ - 캐시           │   │
        │  └──────────────────┘   │
        └──────────┬───────────────┘
                   │
        ┌──────────▼───────────────┐
        │    외부 플랫폼 API        │
        │                          │
        │  - Twitch EventSub       │
        │  - YouTube Live API      │
        │  - SOOP API (계획)       │
        └──────────────────────────┘
```

### 3.3 위젯 URL 시스템 (핵심 메커니즘)

#### 위젯 URL 구조
```
https://your-domain.com/widget/:widgetType/:widgetId?token=xxx

예시:
https://obs-helper.com/widget/alert/abc123?token=eyJhbGc...
https://obs-helper.com/widget/chat/def456?token=eyJhbGc...
```

#### 동작 원리

1. **대시보드에서 위젯 생성**
   - 사용자가 "새 알림 위젯" 클릭
   - 서버가 고유 ID 생성 (UUID)
   - 설정 저장 (색상, 사운드, 애니메이션 등)
   - URL 생성 및 표시

2. **OBS에 URL 추가**
   - 사용자가 URL 복사
   - OBS → 소스 추가 → 브라우저 소스
   - URL 붙여넣기
   - 크기 설정 (1920x1080 등)

3. **위젯 로드 및 WebSocket 연결**
   ```javascript
   // 위젯 페이지 로드 시
   const widgetId = getWidgetIdFromURL();
   const token = getTokenFromURL();

   // WebSocket 연결
   const socket = io('wss://obs-helper.com', {
     auth: { token }
   });

   // 위젯 전용 Room 입장
   socket.emit('join', widgetId);

   // 이벤트 수신
   socket.on('event:follow', (data) => {
     showFollowAlert(data);
   });
   ```

4. **실시간 이벤트 수신 및 표시**
   - Twitch에서 팔로우 발생
   - 백엔드가 WebSocket으로 푸시
   - 위젯이 애니메이션 실행
   - OBS가 화면 캡처

#### 보안 고려사항
- URL에 포함된 JWT 토큰으로 인증
- 토큰은 읽기 전용 권한만 가짐
- 위젯별 독립적인 Room (다른 사용자 데이터 접근 불가)
- CORS 정책으로 불법 iframe 방지

### 3.4 관리자 대시보드 구조

#### 주요 페이지

**1. 홈 / 대시보드**
```
┌─────────────────────────────────────┐
│  오늘의 통계                          │
│  - 팔로워: +12                       │
│  - 구독자: +5                        │
│  - 후원: 15,000원                    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  플랫폼 연동 상태                     │
│  ✅ Twitch: Connected               │
│  ❌ YouTube: Not Connected          │
│  [+ 플랫폼 추가]                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  최근 이벤트                         │
│  🎉 홍길동님이 팔로우했습니다        │
│  💰 김철수님이 5,000원 후원했습니다  │
│  ⭐ 이영희님이 구독했습니다           │
└─────────────────────────────────────┘
```

**2. 위젯 관리**
```
┌──────────────────────────────────────────┐
│  내 위젯 목록                [+ 새 위젯]  │
├──────────────────────────────────────────┤
│  📢 알림 위젯 #1                         │
│  https://obs-helper.com/widget/alert/... │
│  [URL 복사] [설정] [테스트] [삭제]       │
├──────────────────────────────────────────┤
│  💬 채팅 오버레이                         │
│  https://obs-helper.com/widget/chat/...  │
│  [URL 복사] [설정] [테스트] [삭제]       │
└──────────────────────────────────────────┘
```

**3. 위젯 설정 페이지**
```
┌─────────────────────────────────────┐
│  알림 위젯 설정                      │
├─────────────────────────────────────┤
│  기본 설정                           │
│  - 위젯 이름: [메인 알림]            │
│  - 표시 시간: [5초]                  │
│  - 위치: [상단 중앙 ▼]              │
│                                     │
│  스타일                              │
│  - 테마: [기본 테마 ▼]              │
│  - 배경색: [#000000]                │
│  - 텍스트 색: [#FFFFFF]             │
│  - 폰트: [Noto Sans KR ▼]          │
│                                     │
│  애니메이션                          │
│  - 입장: [Slide In ▼]              │
│  - 퇴장: [Fade Out ▼]              │
│                                     │
│  사운드                              │
│  - 팔로우: [기본 사운드 ▼] [업로드]  │
│  - 구독: [기본 사운드 ▼] [업로드]    │
│  - 후원: [기본 사운드 ▼] [업로드]    │
│                                     │
│  고급 설정                           │
│  - 커스텀 CSS: [에디터 열기]         │
│                                     │
│  [저장] [테스트 전송] [미리보기]     │
└─────────────────────────────────────┘
```

**4. 플랫폼 연동**
```
┌─────────────────────────────────────┐
│  Twitch 연동                         │
│  상태: ✅ 연결됨                     │
│  계정: streamer_name                 │
│  연동일: 2025-01-15                  │
│  [연동 해제]                         │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  YouTube 연동                        │
│  상태: ❌ 연결 안 됨                 │
│  [YouTube 계정 연동하기]             │
└─────────────────────────────────────┘
```

**5. 이벤트 히스토리**
```
┌─────────────────────────────────────┐
│  이벤트 기록                         │
│  [오늘 ▼] [전체 ▼]                  │
├─────────────────────────────────────┤
│  2025-01-20 14:30                   │
│  🎉 팔로우: 홍길동                   │
│  플랫폼: Twitch                      │
│  [재생]                              │
├─────────────────────────────────────┤
│  2025-01-20 14:25                   │
│  💰 후원: 김철수 (5,000원)          │
│  플랫폼: Toss                        │
│  [재생]                              │
└─────────────────────────────────────┘
```

### 3.5 컴포넌트 상세 설명

#### A. OBS 브라우저 소스 위젯
- **기술**: Vanilla JS + HTML5 + CSS3
- **크기**: 최소화 (~50KB 이하)
- **CPU 사용**: 1% 미만 목표
- **애니메이션**: GSAP (경량)
- **특징**:
  - 투명 배경 (OBS 합성용)
  - 하드웨어 가속 사용
  - 메모리 누수 방지

#### B. 웹 대시보드
- **기술**: React 18 + TypeScript
- **상태 관리**: Zustand
- **UI**: Tailwind CSS + shadcn/ui
- **특징**:
  - 반응형 디자인
  - 다크 모드 지원
  - 실시간 미리보기

#### C. API Server (NestJS)
- **역할**:
  - RESTful API 제공
  - OAuth 인증 처리
  - 위젯 CRUD
  - 플랫폼 API 연동 관리
- **특징**:
  - Swagger 자동 문서화
  - JWT 기반 인증
  - Rate Limiting

#### D. WebSocket Server (Socket.IO)
- **역할**:
  - 실시간 이벤트 푸시
  - Room 기반 채널 관리
  - 연결 상태 모니터링
- **특징**:
  - Redis Adapter (수평 확장)
  - 자동 재연결
  - 하트비트

#### E. 데이터베이스
- **PostgreSQL**:
  - 사용자 정보
  - 위젯 설정
  - 이벤트 히스토리
  - 플랫폼 연동 정보 (암호화)
- **Redis**:
  - 세션 저장
  - WebSocket 연결 정보
  - API 응답 캐싱
  - Rate Limiting 카운터

## 4. 기술 스택

### 4.1 프론트엔드

#### 웹 대시보드
- **프레임워크**: React 18 + TypeScript
- **상태 관리**: Zustand 또는 Redux Toolkit
- **UI 라이브러리**: Tailwind CSS + shadcn/ui
- **차트**: Recharts 또는 Chart.js
- **빌드 도구**: Vite

#### OBS 위젯
- **기본**: HTML5 + CSS3 + Vanilla JS
- **애니메이션**: GSAP 또는 Anime.js
- **WebSocket 클라이언트**: Socket.io-client
- **최적화**: 경량화, 낮은 CPU 사용률

### 4.2 백엔드

#### API Server
- **런타임**: Node.js 20+
- **프레임워크**: NestJS (TypeScript)
- **검증**: class-validator
- **문서화**: Swagger/OpenAPI

#### WebSocket Server
- **라이브러리**: Socket.io
- **인증**: JWT 기반
- **스케일링**: Redis Adapter

#### 인증
- **전략**: OAuth 2.0
- **라이브러리**: Passport.js
- **토큰**: JWT (Access + Refresh)

### 4.3 데이터베이스

#### PostgreSQL
- **버전**: 15+
- **ORM**: Prisma 또는 TypeORM
- **마이그레이션**: 버전 관리
- **백업**: 자동 백업 설정

#### Redis
- **버전**: 7+
- **용도**:
  - 세션 저장
  - 캐싱
  - Pub/Sub
  - Rate Limiting

### 4.4 인프라

#### 배포
- **컨테이너**: Docker + Docker Compose
- **오케스트레이션**: Kubernetes (프로덕션)
- **CI/CD**: GitHub Actions

#### 모니터링
- **APM**: New Relic 또는 DataDog
- **로깅**: Winston + ELK Stack
- **에러 추적**: Sentry

#### CDN
- **정적 파일**: CloudFlare 또는 AWS CloudFront
- **미디어**: S3 + CDN

## 5. 데이터베이스 스키마

### 5.1 주요 테이블

#### users
```sql
- id (PK)
- email
- username
- avatar_url
- created_at
- updated_at
- last_login
```

#### platform_connections
```sql
- id (PK)
- user_id (FK)
- platform (twitch/youtube/afreeca)
- platform_user_id
- access_token (encrypted)
- refresh_token (encrypted)
- expires_at
- connected_at
- updated_at
```

#### widgets
```sql
- id (PK)
- user_id (FK)
- type (alert/chat/counter/etc)
- name
- settings (JSONB)
- is_active
- created_at
- updated_at
```

#### events
```sql
- id (PK)
- user_id (FK)
- platform
- event_type (follow/subscribe/donation/etc)
- event_data (JSONB)
- processed
- created_at
```

#### widget_themes
```sql
- id (PK)
- user_id (FK)
- widget_type
- theme_name
- css_styles (TEXT)
- is_default
- created_at
```

## 6. API 엔드포인트 설계

### 6.1 인증 API

```
POST   /api/v1/auth/login             # 로그인
POST   /api/v1/auth/logout            # 로그아웃
POST   /api/v1/auth/refresh           # 토큰 갱신
GET    /api/v1/auth/me                # 현재 사용자 정보
```

### 6.2 플랫폼 연동 API

```
GET    /api/v1/platforms                           # 연동 가능한 플랫폼 목록
GET    /api/v1/platforms/connections               # 내 연동 목록
POST   /api/v1/platforms/connect/:platform         # 플랫폼 연동 시작
DELETE /api/v1/platforms/disconnect/:platform      # 플랫폼 연동 해제
GET    /api/v1/platforms/callback/:platform        # OAuth 콜백
```

### 6.3 위젯 API

```
GET    /api/v1/widgets                 # 위젯 목록
GET    /api/v1/widgets/:id             # 위젯 상세
POST   /api/v1/widgets                 # 위젯 생성
PUT    /api/v1/widgets/:id             # 위젯 수정
DELETE /api/v1/widgets/:id             # 위젯 삭제
GET    /api/v1/widgets/:id/url         # 위젯 브라우저 소스 URL
POST   /api/v1/widgets/:id/test        # 위젯 테스트 이벤트 발송
```

### 6.4 이벤트 API

```
GET    /api/v1/events                  # 이벤트 히스토리
GET    /api/v1/events/stats            # 이벤트 통계
POST   /api/v1/events/replay/:id       # 이벤트 재생
```

### 6.5 설정 API

```
GET    /api/v1/settings                # 사용자 설정
PUT    /api/v1/settings                # 설정 업데이트
GET    /api/v1/themes                  # 테마 목록
POST   /api/v1/themes                  # 커스텀 테마 생성
```

### 6.6 WebSocket 이벤트

```
# Client -> Server
authenticate              # JWT 토큰으로 인증
subscribe:widget          # 특정 위젯 구독
unsubscribe:widget        # 위젯 구독 해제

# Server -> Client
event:follow              # 팔로우 이벤트
event:subscribe           # 구독 이벤트
event:donation            # 후원 이벤트
event:chat                # 채팅 메시지
stats:update              # 통계 업데이트
widget:config:update      # 위젯 설정 변경
```

## 7. 보안 고려사항

### 7.1 인증 및 권한
- JWT 토큰 기반 인증
- Access Token (15분) + Refresh Token (7일)
- 토큰 블랙리스트 관리 (Redis)
- Rate Limiting (IP 기반)

### 7.2 데이터 보호
- OAuth 토큰 암호화 저장
- HTTPS 강제
- CORS 설정
- XSS/CSRF 방어

### 7.3 API 보안
- API Key 발급 (써드파티 연동 시)
- Request 검증 및 Sanitization
- SQL Injection 방어
- Rate Limiting

## 8. 성능 최적화

### 8.1 캐싱 전략
- Redis 활용
  - 사용자 세션
  - API 응답 캐싱 (TTL)
  - 실시간 통계

### 8.2 데이터베이스 최적화
- 인덱스 최적화
- 쿼리 최적화
- Connection Pooling
- Read Replica (향후)

### 8.3 프론트엔드 최적화
- Code Splitting
- Lazy Loading
- CDN 활용
- 이미지 최적화

### 8.4 WebSocket 최적화
- Redis Adapter로 수평 확장
- 연결 풀링
- 메시지 압축

## 9. 개발 로드맵

### Phase 1: MVP (3개월)
- [ ] 프로젝트 셋업 및 인프라 구성
- [ ] 인증 시스템 (OAuth)
- [ ] Twitch 연동
- [ ] 기본 위젯 3종 (알림, 채팅, 카운터)
- [ ] 대시보드 기본 기능
- [ ] WebSocket 실시간 통신

### Phase 2: 기능 확장 (2개월)
- [ ] YouTube Live 연동
- [ ] 고급 위젯 추가
- [ ] 커스터마이징 기능
- [ ] 이벤트 히스토리 및 재생
- [ ] 통계 대시보드

### Phase 3: 고도화 (2개월)
- [ ] AfreecaTV 연동
- [ ] 채팅봇 기능
- [ ] 모바일 앱
- [ ] 고급 분석 도구
- [ ] 프리미엄 기능

### Phase 4: 스케일링 (지속)
- [ ] 성능 최적화
- [ ] 인프라 확장
- [ ] 추가 플랫폼 지원
- [ ] 커뮤니티 기능

## 10. 다음 단계

1. **개발 환경 셋업**
   - Node.js, Docker 설치
   - 프로젝트 구조 생성
   - Git 저장소 초기화

2. **프로젝트 초기화**
   - 백엔드 프로젝트 (NestJS)
   - 프론트엔드 프로젝트 (React)
   - 데이터베이스 스키마 정의

3. **첫 번째 기능 개발**
   - OAuth 인증 구현
   - Twitch API 연동
   - 기본 알림 위젯

---

**문서 버전**: 1.0
**작성일**: 2025-10-24
**다음 업데이트**: MVP 완료 후
