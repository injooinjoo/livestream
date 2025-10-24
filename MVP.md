# MVP 정의 - 최소 기능 제품

## MVP의 목표

**"8주 안에 실제로 사용 가능한 제품을 만든다"**

스트리머가 다음 작업을 할 수 있으면 MVP 완성:
1. ✅ 회원가입/로그인
2. ✅ **YouTube** 계정 연동 (검증된 API!)
3. ✅ 알림 위젯 생성
4. ✅ URL을 OBS에 추가
5. ✅ 실제 YouTube 슈퍼챗/구독 → OBS에 알림 표시

### 플랫폼 우선순위 (변경!)
- **1순위**: YouTube Live - API 확실, MVP 검증
- **2순위**: 치지직 (CHZZK) - YouTube 검증 후 추가
- **3순위**: SOOP - 한국 시장 완성
- ⚠️ **Twitch 제외**: 한국 시장 집중

### 전략
1. YouTube로 아키텍처 검증 (Week 7-8)
2. 검증 완료 후 치지직 연동 (Week 9-11)
3. 한국 플랫폼 확장 (SOOP)

---

## Core MVP (Phase 1-4: 8주)

### Week 1-2: 기본 인프라 + 정적 위젯

#### 결과물
- [ ] Docker Compose 환경 (PostgreSQL, Redis)
- [ ] NestJS 백엔드 기본 구조
- [ ] React 프론트엔드 기본 구조
- [ ] 정적 HTML 위젯 하나 (`/widget/alert/test`)
- [ ] 간단한 애니메이션 (GSAP)

#### 테스트 시나리오
```
1. http://localhost:3000/widget/alert/test 접속
2. OBS 브라우저 소스에 URL 추가
3. 화면에 "테스트 알림" 표시 확인
```

#### 우선순위: 🔴 최우선
#### 예상 공수: 40시간

---

### Week 3-4: WebSocket 실시간 통신

#### 결과물
- [ ] Socket.IO 서버 설정
- [ ] 위젯 ID 기반 Room 시스템
- [ ] 위젯에서 WebSocket 연결
- [ ] 테스트 이벤트 전송 API

#### 테스트 시나리오
```
1. OBS에 위젯 URL 추가
2. 웹 브라우저에서 "테스트 알림 전송" 버튼 클릭
3. OBS 화면에 즉시 알림 표시 (새로고침 없이)
```

#### 데이터베이스 스키마 (최소)
```sql
-- 없음 (하드코딩으로 시작)
```

#### 우선순위: 🔴 최우선
#### 예상 공수: 40시간

---

### Week 5-6: 관리자 대시보드 기본

#### 결과물
- [ ] 회원가입/로그인 (이메일 + 비밀번호)
- [ ] JWT 토큰 발급
- [ ] 위젯 생성/수정/삭제 (CRUD)
- [ ] 위젯 URL 복사 기능
- [ ] 테스트 알림 전송 버튼
- [ ] 실시간 미리보기 (iframe)

#### 페이지 구조
```
/login          - 로그인
/register       - 회원가입
/dashboard      - 홈 (통계 요약)
/widgets        - 위젯 목록
/widgets/new    - 새 위젯 생성
/widgets/:id    - 위젯 설정
```

#### 데이터베이스 스키마
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  username VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE widgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'alert', 'chat', 'counter'
  settings JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_widgets_user_id ON widgets(user_id);
CREATE INDEX idx_widgets_type ON widgets(type);
```

#### 테스트 시나리오
```
1. http://localhost:5173 접속
2. 회원가입 후 로그인
3. "새 위젯 만들기" 클릭
4. 알림 메시지, 색상 설정
5. "저장" 클릭
6. 위젯 URL 복사
7. OBS에 URL 추가
8. "테스트 전송" 버튼 클릭
9. OBS 화면에 알림 표시 확인
```

#### 우선순위: 🔴 최우선
#### 예상 공수: 50시간

---

### Week 7-8: YouTube Live 연동 (첫 번째 플랫폼)

#### 결과물
- [ ] Google Cloud Console 프로젝트 생성
- [ ] YouTube Data API v3 활성화
- [ ] OAuth 2.0 인증 플로우 구현
- [ ] Access Token 암호화 저장
- [ ] Refresh Token 갱신 로직
- [ ] Live Chat API Polling (10초 간격)
- [ ] 슈퍼챗 이벤트 수신 및 처리
- [ ] 멤버십 가입 이벤트 (선택적)
- [ ] WebSocket으로 위젯에 푸시
- [ ] 이벤트 히스토리 저장 및 조회
- [ ] 이벤트 재생 기능

#### 왜 YouTube 먼저?
- ✅ API 확실하고 문서화 우수
- ✅ 검증된 OAuth 2.0
- ✅ 많은 예제 코드
- ✅ 치지직 API 조사 완료 전까지

#### 데이터베이스 스키마 추가
```sql
CREATE TABLE platform_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  platform VARCHAR(50) NOT NULL, -- 'chzzk', 'soop', 'youtube', 'twitch'
  platform_user_id VARCHAR(255) NOT NULL,
  platform_username VARCHAR(255),
  access_token TEXT NOT NULL, -- encrypted
  refresh_token TEXT, -- encrypted
  expires_at TIMESTAMP,
  scopes TEXT[],
  connected_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  platform VARCHAR(50) NOT NULL,
  event_type VARCHAR(100) NOT NULL, -- 'follow', 'subscribe', 'donation'
  event_data JSONB NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_events_user_id ON events(user_id);
CREATE INDEX idx_events_created_at ON events(created_at DESC);
CREATE INDEX idx_events_type ON events(event_type);
```

#### YouTube Live 이벤트
- 슈퍼챗 (Super Chat) - 후원
- 슈퍼 스티커 (Super Stickers)
- 멤버십 가입 (Memberships)
- 일반 채팅 메시지

#### 테스트 시나리오
```
1. 대시보드에서 "YouTube 연동" 클릭
2. Google 로그인 페이지로 리다이렉트
3. YouTube 권한 승인
4. 대시보드로 돌아옴 → "연동 완료" 표시
5. YouTube Live 방송 시작
6. 실제 슈퍼챗 발생
7. OBS 화면에 즉시 알림 표시!
8. 대시보드 "이벤트 기록"에서 확인 가능
9. "재생" 버튼으로 다시 보기
```

#### 환경변수 설정
```env
# YouTube OAuth 2.0
YOUTUBE_CLIENT_ID=your_google_client_id
YOUTUBE_CLIENT_SECRET=your_google_client_secret
YOUTUBE_CALLBACK_URL=http://localhost:3000/api/v1/auth/callback/youtube

# Redirect URI (Google Cloud Console에 등록)
# http://localhost:3000/api/v1/auth/callback/youtube
```

#### 참고: 치지직 설정 (Phase 5에서 추가)
```env
CHZZK_CLIENT_ID=to_be_investigated
CHZZK_CLIENT_SECRET=to_be_investigated
CHZZK_CALLBACK_URL=http://localhost:3000/api/v1/auth/callback/chzzk
```

#### 우선순위: 🔴 최우선
#### 예상 공수: 60시간

---

## MVP 완성 체크리스트

### 기능 체크리스트
- [ ] 사용자 회원가입/로그인
- [ ] YouTube OAuth 2.0 연동 (1순위)
- [ ] 알림 위젯 생성
- [ ] 위젯 설정 변경 (메시지, 색상, 사운드)
- [ ] 위젯 URL 복사
- [ ] OBS에서 브라우저 소스로 위젯 추가
- [ ] 실시간 WebSocket 연결
- [ ] YouTube 슈퍼챗/멤버십 이벤트 수신
- [ ] OBS 화면에 알림 표시
- [ ] 사운드 재생
- [ ] 애니메이션 (입장/퇴장)
- [ ] 이벤트 히스토리 조회
- [ ] 이벤트 재생 (테스트)
- [ ] 테스트 알림 전송

### 기술 체크리스트
- [ ] Docker Compose 환경
- [ ] PostgreSQL 연결
- [ ] Redis 연결
- [ ] NestJS API 서버
- [ ] Socket.IO WebSocket 서버
- [ ] React 프론트엔드
- [ ] JWT 인증
- [ ] YouTube API 연동 (googleapis)
- [ ] Live Chat API Polling
- [ ] 암호화 (Access Token)

### 성능 체크리스트
- [ ] 위젯 로드 시간 < 1초
- [ ] 이벤트 표시 지연 < 500ms
- [ ] 위젯 CPU 사용률 < 2%
- [ ] 위젯 메모리 사용 < 50MB

### 보안 체크리스트
- [ ] 비밀번호 해싱 (bcrypt)
- [ ] JWT 토큰 검증
- [ ] Access Token 암호화
- [ ] CORS 설정
- [ ] Rate Limiting
- [ ] XSS 방어
- [ ] SQL Injection 방어

---

## MVP 이후 확장 (Optional)

### Phase 5-6: 기능 확장
- [ ] 사전 제작 테마 5종
- [ ] 커스텀 CSS 에디터
- [ ] 채팅 오버레이 위젯
- [ ] 시청자 카운터 위젯
- [ ] 최근 팔로워 목록 위젯

### Phase 7-8: 한국 시장 완성
- [ ] SOOP (아프리카TV) 연동
- [ ] YouTube Live 연동
- [ ] 멀티 플랫폼 지원 (치지직 + SOOP + YouTube)
- [ ] 통계 대시보드

### Phase 9: 넥슨 게임 연동 🎮 (차별화!)
- [ ] 메이플스토리 플레이 이벤트
  - 레벨업
  - 보스 처치
  - 레어 아이템 드롭
- [ ] 던전앤파이터 지원
- [ ] 카트라이더 지원
- [ ] 로컬 클라이언트 개발
- [ ] 게임 이벤트 알림 위젯

### Phase 10+: 고급 기능
- [ ] 후원 플랫폼 연동 (Toss, Kakaopay)
- [ ] 목표 게이지 위젯
- [ ] 투표/설문 위젯
- [ ] TTS 기능

---

## 개발 가이드

### 각 Phase 시작 전 체크
1. 이전 Phase가 완전히 작동하는지 확인
2. Git에 커밋 및 태그 생성 (`v0.1-phase1` 등)
3. 테스트 시나리오 전체 실행
4. 문서 업데이트

### 개발 원칙
1. **동작하는 것부터**: 완벽하지 않아도 일단 작동하게
2. **점진적 개선**: 기본 → 고급 순서로
3. **테스트 우선**: 매번 실제 OBS에서 테스트
4. **피드백 수용**: 사용자 의견 적극 반영

### 디버깅 팁
- WebSocket 연결: Chrome DevTools → Network → WS 탭
- 위젯 디버그: OBS → 브라우저 소스 우클릭 → "Interact"
- 로그: Winston logger 활용
- 모니터링: Redis Commander, pgAdmin

---

## 성공 기준

### MVP 완성 = 다음 조건을 모두 만족
1. ✅ 실제 스트리머가 5분 안에 설정 가능
2. ✅ YouTube 슈퍼챗이 실시간으로 표시됨
3. ✅ CPU 사용률이 2% 미만
4. ✅ 24시간 연속 작동 (메모리 누수 없음)
5. ✅ 에러 발생 시 자동 복구

### 다음 단계 (MVP 완료 후)
1. ✅ YouTube로 아키텍처 검증 완료
2. 치지직 API 조사 및 연동 (Phase 5)
3. SOOP 연동 (Phase 6)
4. 한국 스트리밍 시장 완전 대응

### 다음 단계로 진행 조건
- 최소 10명의 테스터가 실제로 사용
- 피드백 수집 및 우선순위 재조정
- 성능 및 안정성 검증 완료

---

**목표**: 2개월 내 MVP 완성 후 실제 스트리머 테스트 시작
