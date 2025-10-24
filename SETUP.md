# OBS Helper - 개발 환경 설정 가이드

## 필수 요구사항

설치가 필요한 도구들:

- **Node.js** 20+ ([다운로드](https://nodejs.org/))
- **pnpm** 8+ ([설치 가이드](https://pnpm.io/installation))
- **Docker** & **Docker Compose** ([설치 가이드](https://docs.docker.com/get-docker/))
- **Git** ([다운로드](https://git-scm.com/downloads))

## 빠른 시작

### 1. 의존성 설치

```bash
# pnpm 설치 (이미 설치되어 있다면 생략)
npm install -g pnpm

# 프로젝트 의존성 설치
pnpm install
```

### 2. 데이터베이스 실행

```bash
# Docker Compose로 PostgreSQL & Redis 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 3. 데이터베이스 마이그레이션

```bash
# Prisma 클라이언트 생성
cd packages/database
pnpm generate

# 마이그레이션 실행
pnpm migrate

# 루트 디렉토리로 돌아오기
cd ../..
```

### 4. 개발 서버 실행

```bash
# 모든 앱 동시 실행 (backend, frontend, widgets)
pnpm dev
```

개별 실행:
```bash
pnpm dev:backend   # http://localhost:3000
pnpm dev:frontend  # http://localhost:5173
pnpm dev:widgets   # http://localhost:5174
```

### 5. 접속 확인

- 백엔드 API: http://localhost:3000/api/v1/health
- API 문서: http://localhost:3000/api/docs
- 프론트엔드: http://localhost:5173
- 위젯: http://localhost:5174/src/alert/index.html

## 환경 변수 설정

`.env` 파일은 이미 생성되어 있습니다. 필요에 따라 수정하세요:

```bash
# 루트 .env 파일 수정
vim .env

# Frontend .env 파일
vim apps/frontend/.env

# Widgets .env 파일
vim apps/widgets/.env
```

### OAuth 설정 (나중에 필요)

YouTube, CHZZK, SOOP 연동을 위해서는 각 플랫폼에서 OAuth 앱을 생성해야 합니다.

1. **YouTube**: [Google Cloud Console](https://console.cloud.google.com/)
2. **CHZZK**: [치지직 개발자](https://developers.chzzk.naver.com/)
3. **SOOP**: [SOOP 개발자](https://developers.afreecatv.com/)

각 플랫폼에서 받은 Client ID와 Secret을 `.env` 파일에 입력하세요.

## 프로젝트 구조

```
obs-helper/
├── apps/
│   ├── backend/         # NestJS API 서버
│   ├── frontend/        # React 대시보드
│   └── widgets/         # OBS 위젯 (Vanilla JS)
├── packages/
│   ├── shared/          # 공유 타입 & 유틸
│   └── database/        # Prisma 스키마 & 클라이언트
└── infrastructure/
    ├── docker/          # Docker 설정
    └── kubernetes/      # K8s 설정 (프로덕션)
```

## 주요 명령어

### 개발

```bash
pnpm dev              # 모든 앱 실행
pnpm dev:backend      # 백엔드만
pnpm dev:frontend     # 프론트엔드만
pnpm dev:widgets      # 위젯만
```

### 빌드

```bash
pnpm build            # 전체 빌드
pnpm build:backend    # 백엔드만
pnpm build:frontend   # 프론트엔드만
pnpm build:widgets    # 위젯만
```

### 테스트

```bash
pnpm test             # 전체 테스트
pnpm test:cov         # 커버리지 포함
```

### 코드 품질

```bash
pnpm lint             # ESLint 검사
pnpm lint:fix         # 자동 수정
pnpm format           # Prettier 포맷팅
```

### 데이터베이스

```bash
cd packages/database

pnpm generate         # Prisma 클라이언트 생성
pnpm migrate          # 마이그레이션
pnpm studio           # Prisma Studio (DB GUI)
```

### Docker

```bash
docker-compose up -d        # 서비스 시작
docker-compose down         # 서비스 중지
docker-compose logs -f      # 로그 확인
docker-compose ps           # 상태 확인
```

## 문제 해결

### 포트가 이미 사용 중인 경우

```bash
# 포트 사용 중인 프로세스 확인
lsof -i :3000    # 백엔드
lsof -i :5173    # 프론트엔드
lsof -i :5432    # PostgreSQL
lsof -i :6379    # Redis

# 프로세스 종료
kill -9 <PID>
```

### 의존성 문제

```bash
# node_modules 전체 삭제 후 재설치
pnpm clean
pnpm install
```

### 데이터베이스 초기화

```bash
# 모든 데이터 삭제 후 재생성
docker-compose down -v
docker-compose up -d
cd packages/database
pnpm migrate
```

## VS Code 추천 확장

프로젝트를 열면 자동으로 추천 확장이 표시됩니다:

- Prettier - Code formatter
- ESLint
- Prisma
- Tailwind CSS IntelliSense
- Path Intellisense
- Auto Rename Tag
- Error Lens

## 다음 단계

1. ✅ 개발 환경 설정 완료
2. 📖 [ROADMAP.md](./ROADMAP.md) 읽기 - 개발 계획 확인
3. 📖 [MVP.md](./MVP.md) 읽기 - MVP 기능 확인
4. 🔨 Week 1 시작: API Research (API_RESEARCH.md 참고)

## 도움이 필요하신가요?

- 이슈 등록: [GitHub Issues](https://github.com/yourusername/obs-helper/issues)
- 문서: 프로젝트 루트의 .md 파일들 참고

Happy coding! 🚀
