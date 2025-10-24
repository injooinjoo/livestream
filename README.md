# OBS Helper - 스트리밍 도우미 서비스

**위플랩 기반의 웹 네이티브 오버레이 플랫폼**

OBS/XSplit 브라우저 소스에 URL만 추가하면 즉시 작동하는 경량 스트리밍 도우미 서비스입니다.

## 프로젝트 개요

OBS Helper는 위플랩(Weflab)의 핵심 아키텍처를 참고하여 개발된 **오픈소스** 프로젝트입니다.

### 핵심 철학: "URL을 애플리케이션으로"
- ❌ 무거운 프로그램 설치 불필요
- ✅ URL만 복사해서 OBS에 추가
- ✅ 낮은 CPU 사용률 (게임 + 방송에 영향 없음)
- ✅ 서버 업데이트 시 즉시 모든 사용자에게 반영

### 차별점
- 🌟 **오픈소스**: 누구나 기여 가능
- 🇰🇷 **한국 시장 우선**: SOOP, 치지직 지원 계획
- ⚡ **빠른 개발**: 웹 기반으로 신속한 기능 추가
- 🎨 **커스터마이징**: CSS로 자유로운 디자인

## 주요 기능

### ✅ MVP (8주 목표)
**"실제로 사용 가능한 최소 제품"**

1. **위젯 시스템**
   - 알림 위젯 (팔로우, 구독, 후원)
   - URL 기반 (설치 불필요)
   - 실시간 WebSocket 연결

2. **관리자 대시보드**
   - 회원가입/로그인
   - 위젯 생성 및 설정
   - URL 복사 기능
   - 테스트 알림 전송
   - 이벤트 히스토리

3. **플랫폼 연동**
   - Twitch OAuth 인증
   - 팔로우 이벤트 실시간 수신
   - EventSub WebHook

### 🔨 Phase 2 (추가 기능)
- 사전 제작 테마 5종
- 커스텀 CSS 에디터
- 채팅 오버레이
- 시청자 카운터
- 최근 팔로워 목록

### 🚀 Phase 3 (고급 기능)
- YouTube Live 연동
- SOOP/치지직 연동
- 후원 플랫폼 통합
- 목표 게이지
- 투표/설문 위젯

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

## 빠른 시작 (Quick Start)

### 사용자 가이드
1. https://obs-helper.com 접속 (배포 후)
2. 회원가입/로그인
3. "새 위젯 만들기" 클릭
4. 설정 후 URL 복사
5. OBS → 소스 추가 → 브라우저 소스 → URL 붙여넣기
6. 완료! 실시간 알림 작동

### 개발자 가이드

**필수 요구사항**
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

## 개발 로드맵

자세한 로드맵은 [ROADMAP.md](./ROADMAP.md)와 [MVP.md](./MVP.md)를 참고하세요.

### 🎯 Phase 0: 프로젝트 준비 (1주)
- [x] 프로젝트 설계 문서
- [ ] 개발 환경 세팅
- [ ] 프로젝트 구조 생성

### 🔴 Phase 1: 최소 동작 위젯 (2주)
- [ ] 정적 HTML 위젯
- [ ] OBS 브라우저 소스 테스트
- [ ] 테스트 이벤트 시스템

### 🔴 Phase 2: WebSocket 실시간 (2주)
- [ ] Socket.IO 서버
- [ ] 위젯 Room 시스템
- [ ] 실시간 이벤트 푸시

### 🔴 Phase 3: 관리자 대시보드 (2주)
- [ ] 회원가입/로그인
- [ ] 위젯 CRUD
- [ ] URL 복사 기능
- [ ] 테스트 전송

### 🔴 Phase 4: 치지직 연동 (3주)
- [ ] 치지직 API 조사
- [ ] OAuth 인증
- [ ] 실시간 이벤트 수신
- [ ] 팔로우/후원 알림

**MVP 완성 목표: 8주 (2개월)**

### 🟡 Phase 5-8: 한국 시장 완성 (9주)
- [ ] 커스터마이징
- [ ] 추가 위젯 타입
- [ ] SOOP (아프리카TV) 연동
- [ ] YouTube 연동

### 🌟 Phase 9: 넥슨 게임 연동 (4주+)
**차별화 핵심 기능!**
- [ ] 메이플스토리 플레이 이벤트
- [ ] 던파, 카트라이더 등
- [ ] 게임 스트리머 특화

### 🟢 Phase 10+: 고급 기능 (지속)
- [ ] 후원 통합 (Toss, Kakaopay)
- [ ] 고급 위젯 (목표, 투표)
- [ ] 관리자 도구

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 문의

- Issue Tracker: https://github.com/yourusername/obs-helper/issues
- Discord: (준비 중)

## 참고 자료

### 프로젝트 문서
- [설계 문서](./DESIGN.md) - 전체 시스템 아키텍처
- [프로젝트 구조](./PROJECT_STRUCTURE.md) - 폴더 구조 및 코딩 컨벤션
- [로드맵](./ROADMAP.md) - 단계별 개발 계획
- [MVP 정의](./MVP.md) - 최소 기능 제품 명세
- [플랫폼 연동](./PLATFORMS.md) - 치지직, SOOP, YouTube, 넥슨 게임 연동 전략

### 외부 API
- [치지직 개발자](https://developers.chzzk.naver.com/) - 조사 필요
- [SOOP API](https://developers.afreecatv.com/) - 아프리카TV
- [YouTube Live API](https://developers.google.com/youtube/v3/live)
- [Twitch API](https://dev.twitch.tv/docs/api/) - 참고용
- [OBS Browser Source](https://obsproject.com/wiki/Sources-Guide#browsersource)

---

Made with ❤️ for streamers
