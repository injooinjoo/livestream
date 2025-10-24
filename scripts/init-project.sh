#!/bin/bash

# OBS Helper 프로젝트 초기화 스크립트
# 사용법: ./scripts/init-project.sh

set -e  # 에러 발생 시 중단

echo "🚀 OBS Helper 프로젝트 초기화 시작..."
echo ""

# 현재 디렉토리 확인
if [ ! -f "README.md" ]; then
  echo "❌ 에러: 프로젝트 루트 디렉토리에서 실행해주세요."
  exit 1
fi

# 필수 프로그램 확인
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo "❌ $1 이(가) 설치되지 않았습니다."
    echo "   설치 방법: $2"
    exit 1
  else
    echo "✅ $1 설치 확인"
  fi
}

echo "📦 필수 프로그램 확인 중..."
check_command "node" "https://nodejs.org/"
check_command "pnpm" "npm install -g pnpm"
check_command "docker" "https://docs.docker.com/get-docker/"
check_command "docker-compose" "https://docs.docker.com/compose/install/"
echo ""

# 프로젝트 폴더 구조 생성
echo "📁 프로젝트 폴더 구조 생성 중..."

mkdir -p apps/backend/src/{modules,common,config,database}
mkdir -p apps/backend/src/modules/{auth,users,platforms,widgets,events,webhooks}
mkdir -p apps/backend/test/{unit,e2e}
mkdir -p apps/frontend/src/{app,pages,components,features,store,api,routes,utils,styles,types}
mkdir -p apps/frontend/public/assets
mkdir -p apps/widgets/src/{alert,chat,counter,shared,styles}
mkdir -p apps/widgets/public/assets/{sounds,images}
mkdir -p packages/{shared,database,eslint-config}/src
mkdir -p infrastructure/{docker,kubernetes,terraform}
mkdir -p docs
mkdir -p scripts

echo "✅ 폴더 구조 생성 완료"
echo ""

# pnpm-workspace.yaml 생성
echo "📝 pnpm-workspace.yaml 생성 중..."
cat > pnpm-workspace.yaml <<'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF
echo "✅ pnpm-workspace.yaml 생성 완료"
echo ""

# 루트 package.json 생성
echo "📝 루트 package.json 생성 중..."
cat > package.json <<'EOF'
{
  "name": "obs-helper",
  "version": "0.1.0",
  "description": "웹 네이티브 스트리밍 오버레이 플랫폼",
  "private": true,
  "scripts": {
    "dev": "pnpm --parallel --stream dev",
    "build": "pnpm --stream -r build",
    "test": "pnpm --stream -r test",
    "lint": "pnpm --stream -r lint",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "clean": "pnpm --stream -r clean && rm -rf node_modules",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "docker:logs": "docker-compose logs -f"
  },
  "keywords": [
    "obs",
    "streaming",
    "overlay",
    "twitch",
    "youtube",
    "chzzk",
    "soop"
  ],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "prettier": "^3.1.0",
    "turbo": "^1.11.0"
  }
}
EOF
echo "✅ 루트 package.json 생성 완료"
echo ""

# .gitignore 생성
echo "📝 .gitignore 생성 중..."
cat > .gitignore <<'EOF'
# Dependencies
node_modules/
.pnpm-store/

# Environment variables
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
.next/
out/

# Logs
logs/
*.log
npm-debug.log*
pnpm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Database
*.db
*.sqlite
*.sqlite3

# Docker
.dockerignore

# Temporary files
tmp/
temp/
*.tmp
EOF
echo "✅ .gitignore 생성 완료"
echo ""

# .env.example 생성
echo "📝 .env.example 생성 중..."
cat > .env.example <<'EOF'
# Server
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173

# Database
DATABASE_URL=postgresql://obs_helper:password@localhost:5432/obs_helper

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-secret-key-change-this
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# YouTube API
YOUTUBE_CLIENT_ID=your-youtube-client-id
YOUTUBE_CLIENT_SECRET=your-youtube-client-secret
YOUTUBE_CALLBACK_URL=http://localhost:3000/api/v1/auth/callback/youtube

# 치지직 API (조사 후 추가)
CHZZK_CLIENT_ID=
CHZZK_CLIENT_SECRET=
CHZZK_CALLBACK_URL=

# SOOP API (조사 후 추가)
SOOP_CLIENT_ID=
SOOP_CLIENT_SECRET=
SOOP_CALLBACK_URL=

# Webhook
WEBHOOK_BASE_URL=http://localhost:3000
EOF
echo "✅ .env.example 생성 완료"
echo ""

# docker-compose.yml 생성
echo "📝 docker-compose.yml 생성 중..."
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: obs-helper-postgres
    environment:
      POSTGRES_USER: obs_helper
      POSTGRES_PASSWORD: password
      POSTGRES_DB: obs_helper
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U obs_helper"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: obs-helper-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
EOF
echo "✅ docker-compose.yml 생성 완료"
echo ""

# README 파일들 생성
echo "📝 추가 README 파일 생성 중..."

cat > apps/backend/README.md <<'EOF'
# Backend (NestJS)

## 개발 서버 실행

```bash
pnpm install
pnpm dev
```

## 환경 변수

`.env` 파일을 루트에 생성하세요. (`.env.example` 참고)

## API 문서

개발 서버 실행 후: http://localhost:3000/api/docs
EOF

cat > apps/frontend/README.md <<'EOF'
# Frontend (React + Vite)

## 개발 서버 실행

```bash
pnpm install
pnpm dev
```

## 빌드

```bash
pnpm build
```
EOF

cat > apps/widgets/README.md <<'EOF'
# Widgets (Vanilla JS)

OBS 브라우저 소스용 경량 위젯

## 개발

```bash
pnpm install
pnpm dev
```

## 위젯 종류

- alert: 알림 위젯
- chat: 채팅 오버레이
- counter: 시청자 카운터
EOF

echo "✅ README 파일 생성 완료"
echo ""

# 의존성 설치 여부 확인
read -p "📦 의존성을 설치하시겠습니까? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "📦 의존성 설치 중..."
  pnpm install
  echo "✅ 의존성 설치 완료"
else
  echo "⏭️  의존성 설치를 건너뜁니다."
fi
echo ""

# Docker 서비스 시작 여부 확인
read -p "🐳 Docker 서비스(PostgreSQL, Redis)를 시작하시겠습니까? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "🐳 Docker 서비스 시작 중..."
  docker-compose up -d
  echo "⏳ 서비스 초기화 대기 중 (10초)..."
  sleep 10
  docker-compose ps
  echo "✅ Docker 서비스 시작 완료"
else
  echo "⏭️  Docker 서비스 시작을 건너뜁니다."
fi
echo ""

echo "✨ 프로젝트 초기화 완료!"
echo ""
echo "📋 다음 단계:"
echo "  1. 각 앱의 package.json 설정 (backend, frontend, widgets)"
echo "  2. Backend: NestJS 프로젝트 초기화"
echo "  3. Frontend: React + Vite 프로젝트 초기화"
echo "  4. Database: Prisma 스키마 작성"
echo ""
echo "🔗 참고 문서:"
echo "  - ROADMAP.md: 개발 계획"
echo "  - MVP.md: 최소 기능 제품 정의"
echo "  - API_RESEARCH.md: API 조사 계획"
echo "  - PLATFORMS.md: 플랫폼 연동 전략"
echo ""
echo "🚀 개발 시작: pnpm dev"
