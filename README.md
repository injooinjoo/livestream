# OBS Helper - 스트리밍 도우미 서비스

OBS/XSplit과 연동하여 스트리머들이 방송을 효율적으로 관리할 수 있도록 돕는 통합 도우미 서비스입니다.

## 프로젝트 개요

OBS Helper는 위플랩, 아프리카도우미와 같은 스트리밍 도우미 서비스를 참고하여 개발된 오픈소스 프로젝트입니다. 다양한 스트리밍 플랫폼(Twitch, YouTube, AfreecaTV)과 연동하여 실시간 알림, 채팅 오버레이, 통계 등을 제공합니다.

## 주요 기능

### Phase 1: MVP
- OAuth 2.0 기반 인증 시스템
- Twitch 플랫폼 연동
- 기본 위젯 3종
  - 알림 위젯 (팔로우, 구독, 후원)
  - 채팅 오버레이
  - 시청자 카운터
- 웹 대시보드
- WebSocket 실시간 통신

### Phase 2: 기능 확장 (계획)
- YouTube Live 연동
- 고급 위젯 (목표 게이지, 투표 등)
- 커스터마이징 기능
- 이벤트 히스토리 및 재생
- 통계 대시보드

### Phase 3: 고도화 (계획)
- AfreecaTV 연동
- 채팅봇 기능
- 모바일 앱
- 고급 분석 도구

## 기술 스택

### 프론트엔드
- **대시보드**: React 18 + TypeScript + Vite
- **상태 관리**: Zustand
- **UI**: Tailwind CSS + shadcn/ui
- **위젯**: HTML5 + Vanilla JS + GSAP

### 백엔드
- **프레임워크**: NestJS + TypeScript
- **실시간 통신**: Socket.io
- **인증**: Passport.js + JWT

### 데이터베이스
- **주 데이터베이스**: PostgreSQL 15+
- **캐시**: Redis 7+
- **ORM**: Prisma

### 인프라
- **컨테이너**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **배포**: Kubernetes (프로덕션)

## 프로젝트 구조

```
obs-helper/
├── apps/
│   ├── backend/         # NestJS 백엔드 서버
│   ├── frontend/        # React 대시보드
│   └── widgets/         # OBS 위젯
├── packages/
│   ├── shared/          # 공유 타입, 유틸리티
│   ├── database/        # Prisma 스키마
│   └── eslint-config/   # ESLint 설정
├── infrastructure/      # Docker, K8s 설정
└── docs/               # 문서
```

자세한 구조는 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)를 참고하세요.

## 시작하기

### 필수 요구사항

- Node.js 20+
- pnpm 8+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### 설치

```bash
# 저장소 클론
git clone https://github.com/yourusername/obs-helper.git
cd obs-helper

# 의존성 설치
pnpm install

# 환경변수 설정
cp .env.example .env
# .env 파일을 수정하여 필요한 값들을 설정하세요

# 데이터베이스 마이그레이션
pnpm --filter @obs-helper/database migrate

# 개발 서버 실행
pnpm dev
```

### Docker Compose로 실행

```bash
# 전체 스택 실행 (PostgreSQL, Redis, Backend, Frontend)
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 중지
docker-compose down
```

## 개발

### 개발 서버 실행

```bash
# 모든 앱 실행
pnpm dev

# 특정 앱만 실행
pnpm --filter backend dev      # 백엔드만
pnpm --filter frontend dev     # 프론트엔드만
pnpm --filter widgets dev      # 위젯만
```

### 빌드

```bash
# 전체 빌드
pnpm build

# 특정 앱만 빌드
pnpm --filter backend build
pnpm --filter frontend build
```

### 테스트

```bash
# 전체 테스트
pnpm test

# 특정 앱 테스트
pnpm --filter backend test
pnpm --filter frontend test

# 커버리지 확인
pnpm test:cov
```

### 코드 품질

```bash
# Lint 검사
pnpm lint

# Lint 자동 수정
pnpm lint:fix

# 포맷팅
pnpm format
```

## 환경변수

### Backend (.env)

```env
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/obs_helper

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# OAuth - Twitch
TWITCH_CLIENT_ID=your-twitch-client-id
TWITCH_CLIENT_SECRET=your-twitch-client-secret
TWITCH_CALLBACK_URL=http://localhost:3000/api/v1/auth/callback/twitch

# OAuth - YouTube
YOUTUBE_CLIENT_ID=your-youtube-client-id
YOUTUBE_CLIENT_SECRET=your-youtube-client-secret
YOUTUBE_CALLBACK_URL=http://localhost:3000/api/v1/auth/callback/youtube
```

### Frontend (.env)

```env
VITE_API_URL=http://localhost:3000
VITE_WS_URL=ws://localhost:3000
```

## API 문서

백엔드 서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:
- Swagger UI: http://localhost:3000/api/docs

## 위젯 사용법

1. 대시보드에 로그인
2. 플랫폼(Twitch/YouTube) 계정 연동
3. 위젯 생성 및 설정
4. 위젯 URL 복사
5. OBS/XSplit의 브라우저 소스에 URL 추가

## 아키텍처

자세한 시스템 아키텍처는 [DESIGN.md](./DESIGN.md)를 참고하세요.

### 주요 컴포넌트

```
┌─────────────────────────────────────┐
│     OBS/XSplit (브라우저 소스)        │
└──────────────┬──────────────────────┘
               │ WebSocket
┌──────────────┴──────────────────────┐
│          웹 대시보드                 │
└──────────────┬──────────────────────┘
               │ HTTP/WS
┌──────────────┴──────────────────────┐
│         API Gateway                 │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│       백엔드 서버 클러스터            │
│  ┌──────────┐    ┌──────────┐      │
│  │ REST API │    │ WebSocket│      │
│  └──────────┘    └──────────┘      │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│    PostgreSQL  │  Redis             │
└─────────────────────────────────────┘
               │
┌──────────────┴──────────────────────┐
│  Twitch API │ YouTube API           │
└─────────────────────────────────────┘
```

## 기여하기

프로젝트에 기여를 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### 코딩 컨벤션

- ESLint + Prettier 사용
- TypeScript strict 모드
- 컴포넌트: `PascalCase.tsx`
- 서비스/유틸: `camelCase.ts`
- 명확한 타입 정의

## 로드맵

### Q1 2025 - Phase 1: MVP
- [x] 프로젝트 설계
- [ ] 프로젝트 초기 설정
- [ ] 인증 시스템 구현
- [ ] Twitch 연동
- [ ] 기본 위젯 3종 개발
- [ ] 대시보드 MVP

### Q2 2025 - Phase 2: 기능 확장
- [ ] YouTube Live 연동
- [ ] 고급 위젯 개발
- [ ] 커스터마이징 기능
- [ ] 통계 대시보드

### Q3 2025 - Phase 3: 고도화
- [ ] AfreecaTV 연동
- [ ] 채팅봇 기능
- [ ] 모바일 앱
- [ ] 프리미엄 기능

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 문의

- Issue Tracker: https://github.com/yourusername/obs-helper/issues
- Discord: (준비 중)

## 참고 자료

- [설계 문서](./DESIGN.md)
- [프로젝트 구조](./PROJECT_STRUCTURE.md)
- [Twitch API](https://dev.twitch.tv/docs/api/)
- [YouTube Live API](https://developers.google.com/youtube/v3/live)
- [OBS Browser Source](https://obsproject.com/wiki/Sources-Guide#browsersource)

---

Made with ❤️ for streamers
