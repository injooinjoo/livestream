# OBS Helper - 프로젝트 구조

## 1. 전체 프로젝트 구조

```
obs-helper/
├── apps/
│   ├── backend/                 # NestJS 백엔드 서버
│   ├── frontend/                # React 대시보드
│   └── widgets/                 # OBS 위젯 (경량 HTML/JS)
├── packages/
│   ├── shared/                  # 공유 타입, 유틸리티
│   ├── database/                # Prisma 스키마 및 마이그레이션
│   └── eslint-config/           # ESLint 공유 설정
├── infrastructure/
│   ├── docker/                  # Docker 설정
│   ├── kubernetes/              # K8s 배포 설정
│   └── terraform/               # 인프라 as Code
├── docs/                        # 문서
├── scripts/                     # 빌드/배포 스크립트
├── .github/
│   └── workflows/               # GitHub Actions CI/CD
├── docker-compose.yml
├── package.json
├── pnpm-workspace.yaml
└── README.md
```

## 2. Backend 구조 (NestJS)

```
apps/backend/
├── src/
│   ├── modules/
│   │   ├── auth/                    # 인증 모듈
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── strategies/
│   │   │   │   ├── jwt.strategy.ts
│   │   │   │   ├── oauth-twitch.strategy.ts
│   │   │   │   └── oauth-youtube.strategy.ts
│   │   │   ├── guards/
│   │   │   │   ├── jwt-auth.guard.ts
│   │   │   │   └── roles.guard.ts
│   │   │   └── dto/
│   │   │       ├── login.dto.ts
│   │   │       └── register.dto.ts
│   │   │
│   │   ├── users/                   # 사용자 모듈
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   ├── users.module.ts
│   │   │   ├── entities/
│   │   │   │   └── user.entity.ts
│   │   │   └── dto/
│   │   │       ├── create-user.dto.ts
│   │   │       └── update-user.dto.ts
│   │   │
│   │   ├── platforms/               # 플랫폼 연동 모듈
│   │   │   ├── platforms.controller.ts
│   │   │   ├── platforms.service.ts
│   │   │   ├── platforms.module.ts
│   │   │   ├── providers/
│   │   │   │   ├── twitch/
│   │   │   │   │   ├── twitch.service.ts
│   │   │   │   │   ├── twitch.events.ts
│   │   │   │   │   └── twitch.types.ts
│   │   │   │   ├── youtube/
│   │   │   │   │   ├── youtube.service.ts
│   │   │   │   │   ├── youtube.events.ts
│   │   │   │   │   └── youtube.types.ts
│   │   │   │   └── afreecatv/
│   │   │   │       ├── afreeca.service.ts
│   │   │   │       └── afreeca.types.ts
│   │   │   └── entities/
│   │   │       └── platform-connection.entity.ts
│   │   │
│   │   ├── widgets/                 # 위젯 모듈
│   │   │   ├── widgets.controller.ts
│   │   │   ├── widgets.service.ts
│   │   │   ├── widgets.module.ts
│   │   │   ├── entities/
│   │   │   │   ├── widget.entity.ts
│   │   │   │   └── widget-theme.entity.ts
│   │   │   └── dto/
│   │   │       ├── create-widget.dto.ts
│   │   │       └── update-widget.dto.ts
│   │   │
│   │   ├── events/                  # 이벤트 처리 모듈
│   │   │   ├── events.controller.ts
│   │   │   ├── events.service.ts
│   │   │   ├── events.module.ts
│   │   │   ├── events.gateway.ts    # WebSocket Gateway
│   │   │   ├── processors/
│   │   │   │   ├── follow.processor.ts
│   │   │   │   ├── subscribe.processor.ts
│   │   │   │   ├── donation.processor.ts
│   │   │   │   └── chat.processor.ts
│   │   │   └── entities/
│   │   │       └── event.entity.ts
│   │   │
│   │   ├── webhooks/                # 외부 Webhook 수신
│   │   │   ├── webhooks.controller.ts
│   │   │   ├── webhooks.service.ts
│   │   │   └── webhooks.module.ts
│   │   │
│   │   └── analytics/               # 분석 모듈
│   │       ├── analytics.controller.ts
│   │       ├── analytics.service.ts
│   │       └── analytics.module.ts
│   │
│   ├── common/
│   │   ├── decorators/              # 커스텀 데코레이터
│   │   │   ├── current-user.decorator.ts
│   │   │   └── roles.decorator.ts
│   │   ├── filters/                 # Exception Filters
│   │   │   └── http-exception.filter.ts
│   │   ├── guards/                  # Guards
│   │   │   └── throttle.guard.ts
│   │   ├── interceptors/            # Interceptors
│   │   │   ├── logging.interceptor.ts
│   │   │   └── transform.interceptor.ts
│   │   ├── pipes/                   # Validation Pipes
│   │   │   └── validation.pipe.ts
│   │   └── middleware/              # Middleware
│   │       └── logger.middleware.ts
│   │
│   ├── config/                      # 설정 파일
│   │   ├── app.config.ts
│   │   ├── database.config.ts
│   │   ├── redis.config.ts
│   │   └── oauth.config.ts
│   │
│   ├── database/
│   │   ├── migrations/              # 데이터베이스 마이그레이션
│   │   └── seeders/                 # 시드 데이터
│   │
│   ├── app.module.ts
│   └── main.ts
│
├── test/
│   ├── unit/
│   └── e2e/
│
├── .env.example
├── .eslintrc.js
├── .prettierrc
├── nest-cli.json
├── package.json
├── tsconfig.json
└── README.md
```

## 3. Frontend 구조 (React)

```
apps/frontend/
├── public/
│   ├── index.html
│   └── assets/
│       ├── images/
│       └── fonts/
│
├── src/
│   ├── app/                         # 앱 루트
│   │   ├── App.tsx
│   │   ├── App.css
│   │   └── providers/
│   │       ├── AuthProvider.tsx
│   │       ├── ThemeProvider.tsx
│   │       └── SocketProvider.tsx
│   │
│   ├── pages/                       # 페이지 컴포넌트
│   │   ├── auth/
│   │   │   ├── LoginPage.tsx
│   │   │   ├── RegisterPage.tsx
│   │   │   └── CallbackPage.tsx
│   │   ├── dashboard/
│   │   │   ├── DashboardPage.tsx
│   │   │   └── OverviewPage.tsx
│   │   ├── widgets/
│   │   │   ├── WidgetsListPage.tsx
│   │   │   ├── WidgetCreatePage.tsx
│   │   │   ├── WidgetEditPage.tsx
│   │   │   └── WidgetPreviewPage.tsx
│   │   ├── platforms/
│   │   │   ├── PlatformsPage.tsx
│   │   │   └── ConnectPlatformPage.tsx
│   │   ├── events/
│   │   │   ├── EventsHistoryPage.tsx
│   │   │   └── EventsStatsPage.tsx
│   │   ├── settings/
│   │   │   ├── SettingsPage.tsx
│   │   │   ├── ProfileSettings.tsx
│   │   │   └── ThemeSettings.tsx
│   │   └── analytics/
│   │       └── AnalyticsPage.tsx
│   │
│   ├── components/                  # 재사용 가능한 컴포넌트
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Layout.tsx
│   │   ├── widgets/
│   │   │   ├── WidgetCard.tsx
│   │   │   ├── WidgetPreview.tsx
│   │   │   ├── WidgetSettings.tsx
│   │   │   └── WidgetUrlDisplay.tsx
│   │   ├── forms/
│   │   │   ├── Input.tsx
│   │   │   ├── Button.tsx
│   │   │   ├── Select.tsx
│   │   │   └── ColorPicker.tsx
│   │   ├── charts/
│   │   │   ├── LineChart.tsx
│   │   │   ├── BarChart.tsx
│   │   │   └── PieChart.tsx
│   │   └── common/
│   │       ├── Loading.tsx
│   │       ├── ErrorBoundary.tsx
│   │       ├── Modal.tsx
│   │       └── Toast.tsx
│   │
│   ├── features/                    # 기능별 모듈
│   │   ├── auth/
│   │   │   ├── hooks/
│   │   │   │   ├── useAuth.ts
│   │   │   │   └── useOAuth.ts
│   │   │   ├── services/
│   │   │   │   └── auth.service.ts
│   │   │   └── types/
│   │   │       └── auth.types.ts
│   │   ├── widgets/
│   │   │   ├── hooks/
│   │   │   │   ├── useWidgets.ts
│   │   │   │   └── useWidgetSettings.ts
│   │   │   ├── services/
│   │   │   │   └── widgets.service.ts
│   │   │   └── types/
│   │   │       └── widgets.types.ts
│   │   └── events/
│   │       ├── hooks/
│   │       │   ├── useEvents.ts
│   │       │   └── useWebSocket.ts
│   │       ├── services/
│   │       │   └── events.service.ts
│   │       └── types/
│   │           └── events.types.ts
│   │
│   ├── store/                       # 상태 관리
│   │   ├── slices/
│   │   │   ├── authSlice.ts
│   │   │   ├── widgetsSlice.ts
│   │   │   └── eventsSlice.ts
│   │   └── index.ts
│   │
│   ├── api/                         # API 클라이언트
│   │   ├── client.ts
│   │   ├── interceptors.ts
│   │   └── endpoints/
│   │       ├── auth.ts
│   │       ├── widgets.ts
│   │       ├── events.ts
│   │       └── platforms.ts
│   │
│   ├── routes/                      # 라우팅
│   │   ├── index.tsx
│   │   ├── PrivateRoute.tsx
│   │   └── PublicRoute.tsx
│   │
│   ├── utils/                       # 유틸리티
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── constants.ts
│   │
│   ├── styles/                      # 스타일
│   │   ├── globals.css
│   │   ├── tailwind.css
│   │   └── themes/
│   │       ├── light.css
│   │       └── dark.css
│   │
│   ├── types/                       # 타입 정의
│   │   ├── api.types.ts
│   │   └── common.types.ts
│   │
│   ├── main.tsx
│   └── vite-env.d.ts
│
├── .env.example
├── .eslintrc.js
├── index.html
├── package.json
├── postcss.config.js
├── tailwind.config.js
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 4. Widgets 구조 (OBS 위젯)

```
apps/widgets/
├── public/
│   └── assets/
│       ├── sounds/                  # 알림 사운드
│       └── images/                  # 기본 이미지
│
├── src/
│   ├── alert/                       # 알림 위젯
│   │   ├── index.html
│   │   ├── alert.ts
│   │   ├── alert.css
│   │   └── templates/
│   │       ├── follow.html
│   │       ├── subscribe.html
│   │       └── donation.html
│   │
│   ├── chat/                        # 채팅 오버레이
│   │   ├── index.html
│   │   ├── chat.ts
│   │   └── chat.css
│   │
│   ├── counter/                     # 시청자 카운터
│   │   ├── index.html
│   │   ├── counter.ts
│   │   └── counter.css
│   │
│   ├── recent-events/               # 최근 이벤트
│   │   ├── index.html
│   │   ├── recent-events.ts
│   │   └── recent-events.css
│   │
│   ├── goal/                        # 목표 게이지
│   │   ├── index.html
│   │   ├── goal.ts
│   │   └── goal.css
│   │
│   ├── shared/                      # 공유 코드
│   │   ├── websocket.ts             # WebSocket 클라이언트
│   │   ├── animations.ts            # 애니메이션 유틸
│   │   ├── audio.ts                 # 오디오 재생
│   │   └── utils.ts                 # 유틸리티
│   │
│   └── styles/
│       ├── common.css               # 공통 스타일
│       └── animations.css           # 애니메이션
│
├── scripts/
│   └── build.js                     # 빌드 스크립트
│
├── package.json
└── README.md
```

## 5. Shared Package 구조

```
packages/shared/
├── src/
│   ├── types/
│   │   ├── user.types.ts
│   │   ├── widget.types.ts
│   │   ├── event.types.ts
│   │   ├── platform.types.ts
│   │   └── index.ts
│   │
│   ├── constants/
│   │   ├── event-types.ts
│   │   ├── widget-types.ts
│   │   ├── platforms.ts
│   │   └── index.ts
│   │
│   ├── utils/
│   │   ├── validation.ts
│   │   ├── formatting.ts
│   │   └── index.ts
│   │
│   └── index.ts
│
├── package.json
└── tsconfig.json
```

## 6. Database Package 구조

```
packages/database/
├── prisma/
│   ├── schema.prisma                # Prisma 스키마
│   ├── migrations/                  # 마이그레이션
│   └── seed.ts                      # 시드 데이터
│
├── src/
│   ├── client.ts                    # Prisma 클라이언트
│   └── types.ts                     # 생성된 타입
│
├── package.json
└── README.md
```

## 7. Infrastructure 구조

```
infrastructure/
├── docker/
│   ├── backend/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   ├── frontend/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── nginx/
│       ├── Dockerfile
│       └── nginx.conf
│
├── kubernetes/
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   └── secrets.yaml
│   ├── deployments/
│   │   ├── backend.yaml
│   │   ├── frontend.yaml
│   │   ├── redis.yaml
│   │   └── postgres.yaml
│   ├── services/
│   │   ├── backend-service.yaml
│   │   ├── frontend-service.yaml
│   │   └── ingress.yaml
│   └── kustomization.yaml
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── vpc/
        ├── eks/
        ├── rds/
        └── elasticache/
```

## 8. 개발 워크플로우

### 8.1 로컬 개발 환경 실행

```bash
# 1. 의존성 설치
pnpm install

# 2. 환경변수 설정
cp .env.example .env

# 3. 데이터베이스 마이그레이션
pnpm --filter @obs-helper/database migrate

# 4. 개발 서버 실행
pnpm dev
```

### 8.2 Docker Compose 실행

```bash
# 전체 스택 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 중지
docker-compose down
```

### 8.3 빌드 및 배포

```bash
# 프로덕션 빌드
pnpm build

# Docker 이미지 빌드
pnpm docker:build

# 배포
pnpm deploy
```

## 9. 코딩 컨벤션

### 9.1 파일 명명 규칙
- 컴포넌트: `PascalCase.tsx` (예: `WidgetCard.tsx`)
- 서비스: `camelCase.service.ts` (예: `auth.service.ts`)
- 타입: `camelCase.types.ts` (예: `user.types.ts`)
- 유틸: `camelCase.ts` (예: `formatters.ts`)

### 9.2 코드 스타일
- ESLint + Prettier 사용
- TypeScript strict 모드
- 함수형 프로그래밍 선호
- 명확한 타입 정의

### 9.3 Git 브랜치 전략
- `main`: 프로덕션
- `develop`: 개발
- `feature/*`: 새 기능
- `fix/*`: 버그 수정
- `refactor/*`: 리팩토링

## 10. 테스팅 전략

### 10.1 백엔드
- Unit Tests: Jest
- E2E Tests: Supertest
- Coverage: 80% 이상

### 10.2 프론트엔드
- Unit Tests: Vitest
- Component Tests: Testing Library
- E2E Tests: Playwright

### 10.3 위젯
- 수동 테스트 (OBS 환경)
- 성능 테스트 (CPU/메모리 사용률)

---

**다음 단계**: 실제 프로젝트 폴더 구조 생성 및 초기 설정
