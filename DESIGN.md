# OBS Helper - 스트리밍 도우미 서비스 설계 문서

## 1. 프로젝트 개요

### 1.1 목적
OBS/XSplit과 연동하여 스트리머들이 방송을 효율적으로 관리할 수 있도록 돕는 통합 도우미 서비스

### 1.2 주요 타겟
- 개인 스트리머
- 프로 게임단 및 미디어 크리에이터
- MCN 소속 크리에이터

### 1.3 참고 서비스
- 위플랩 (Whiplab)
- 아프리카도우미
- StreamElements
- Streamlabs

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

### 3.1 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                         클라이언트                            │
├─────────────────┬─────────────────┬─────────────────────────┤
│   OBS/XSplit    │   웹 대시보드    │    모바일 앱 (Phase 2)   │
│  (브라우저 소스)  │   (React/Vue)   │     (React Native)      │
└────────┬────────┴────────┬────────┴────────┬────────────────┘
         │                 │                 │
         │      HTTPS      │      HTTPS      │      HTTPS
         │                 │                 │
         └─────────────────┼─────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │          API Gateway              │
         │         (Load Balancer)           │
         └─────────────────┬─────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │         백엔드 서버 클러스터         │
         │                                   │
         │  ┌────────────┐  ┌────────────┐  │
         │  │ API Server │  │ WebSocket  │  │
         │  │ (REST API) │  │   Server   │  │
         │  └──────┬─────┘  └──────┬─────┘  │
         │         │                │        │
         │    ┌────┴────────────────┴────┐  │
         │    │   Event Processing      │  │
         │    │      (Queue Worker)      │  │
         │    └────────────┬─────────────┘  │
         └─────────────────┼─────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │          데이터 레이어             │
         │                                   │
         │  ┌────────────┐  ┌────────────┐  │
         │  │ PostgreSQL │  │   Redis    │  │
         │  │  (Primary) │  │  (Cache)   │  │
         │  └────────────┘  └────────────┘  │
         │                                   │
         │  ┌────────────┐  ┌────────────┐  │
         │  │   S3/CDN   │  │   Queue    │  │
         │  │  (Assets)  │  │ (RabbitMQ) │  │
         │  └────────────┘  └────────────┘  │
         └───────────────────────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │        외부 서비스 연동             │
         │                                   │
         │   Twitch API  │  YouTube API      │
         │   AfreecaTV   │  Payment Gateway  │
         └───────────────────────────────────┘
```

### 3.2 컴포넌트 설명

#### 3.2.1 프론트엔드
- **OBS 브라우저 소스**: 경량 HTML/CSS/JS 위젯
- **웹 대시보드**: 관리 및 설정 인터페이스
- **모바일 앱**: 모바일 관리 및 모니터링

#### 3.2.2 백엔드
- **API Server**: RESTful API 제공
- **WebSocket Server**: 실시간 데이터 푸시
- **Event Processor**: 비동기 이벤트 처리
- **Queue Worker**: 백그라운드 작업 처리

#### 3.2.3 데이터
- **PostgreSQL**: 사용자, 설정, 히스토리 저장
- **Redis**: 세션, 캐시, 실시간 데이터
- **S3/CDN**: 정적 파일 및 미디어
- **Message Queue**: 이벤트 큐잉

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
