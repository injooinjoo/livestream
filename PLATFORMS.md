# 플랫폼 연동 전략

## 목표 플랫폼

### 우선순위 1: 스트리밍 플랫폼
1. **치지직 (CHZZK)** - 네이버, 한국 시장
2. **SOOP (아프리카TV)** - 한국 최대
3. **YouTube Live** - 글로벌, API 안정적

### 우선순위 2: 넥슨 게임 연동 🎮
- 넥슨 게임 플레이 이벤트를 실시간 오버레이로 표시
- **차별화 핵심 기능**: 위플랩, StreamElements에 없는 독창적 기능

### ⚠️ 제외: Twitch
- 한국 시장 집중을 위해 제외
- 글로벌 확장 필요 시 추후 추가

---

## 1. 치지직 (CHZZK) 연동

### 플랫폼 정보
- **운영사**: 네이버
- **출시**: 2023년
- **특징**: 네이버 생태계 통합, 빠르게 성장 중
- **타겟**: 게임 스트리머 중심

### API 조사 필요 사항
```
[ ] 공식 API 존재 여부
[ ] OAuth 2.0 지원
[ ] 실시간 이벤트 수신 방식
    - WebHook
    - WebSocket
    - Polling
[ ] 지원 이벤트 타입
    - 팔로우
    - 구독 (후원)
    - 채팅
    - 도네이션
[ ] Rate Limiting
[ ] 개발자 등록 방법
```

### 예상 연동 방식
```javascript
// 1. OAuth 인증
GET https://chzzk.naver.com/oauth/authorize
POST https://chzzk.naver.com/oauth/token

// 2. 이벤트 수신 (예상)
// Option A: WebHook
POST /webhooks/chzzk
{
  "event": "follow",
  "user": { "id": "xxx", "name": "홍길동" },
  "timestamp": "2025-01-20T10:00:00Z"
}

// Option B: WebSocket
wss://chzzk.naver.com/events?access_token=xxx

// Option C: Polling (최악의 경우)
GET https://api.chzzk.naver.com/v1/channels/{channelId}/events
```

### 개발 계획
- **Phase 4**: 치지직 우선 연동
- **예상 기간**: 3주
- **대체안**: 공식 API 없을 경우 크롬 익스텐션 방식 검토

---

## 2. SOOP (아프리카TV) 연동

### 플랫폼 정보
- **이전 이름**: 아프리카TV (AfreecaTV)
- **특징**: 한국 최대 1인 방송 플랫폼
- **타겟**: 게임, 먹방, 토크 등 다양

### API 정보
```
[ ] 공식 API: https://developers.afreecatv.com
[ ] OAuth 2.0 지원 여부
[ ] 실시간 이벤트
    - 별풍선 (후원)
    - 팬가입
    - 채팅
[ ] 아프리카도우미 API 참고
```

### 예상 연동 방식
```javascript
// 별풍선 (스티커) 이벤트
{
  "event": "sticker",
  "user": "홍길동",
  "sticker_name": "햄버거",
  "amount": 10000,
  "message": "감사합니다!"
}

// 팬가입 이벤트
{
  "event": "fan",
  "user": "김철수",
  "fan_level": 1
}
```

### 개발 계획
- **Phase 5**: SOOP 연동 (치지직 다음)
- **예상 기간**: 2주
- **참고**: 아프리카도우미 분석

---

## 3. YouTube Live 연동

### 플랫폼 정보
- **운영사**: Google
- **특징**: 글로벌 플랫폼, 안정적인 API
- **장점**: 풍부한 문서화

### API 정보
- **공식 API**: YouTube Data API v3 + YouTube Live Streaming API
- **OAuth 2.0**: 완벽 지원
- **실시간 이벤트**: Live Chat API

### 주요 이벤트
```javascript
// 구독 이벤트
{
  "kind": "youtube#subscription",
  "snippet": {
    "channelId": "UC...",
    "title": "홍길동"
  }
}

// 슈퍼챗 (후원)
{
  "kind": "youtube#superChatEvent",
  "snippet": {
    "displayMessage": "응원합니다!",
    "amountMicros": "5000000", // 5,000원
    "currency": "KRW"
  }
}

// 채팅 메시지
{
  "kind": "youtube#liveChatMessage",
  "snippet": {
    "displayMessage": "안녕하세요",
    "authorChannelId": "UC..."
  }
}
```

### 연동 방식
```javascript
// 1. OAuth 2.0
const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI
);

// 2. Live Chat 모니터링 (Polling 방식)
const response = await youtube.liveChatMessages.list({
  liveChatId: 'abc123',
  part: 'snippet,authorDetails'
});

// 3. 이벤트 변환 → WebSocket 푸시
for (const message of response.data.items) {
  if (message.snippet.type === 'superChatEvent') {
    socket.to(widgetId).emit('event:donation', {
      platform: 'youtube',
      user: message.authorDetails.displayName,
      amount: message.snippet.superChatDetails.amountMicros / 1000000,
      message: message.snippet.superChatDetails.userComment
    });
  }
}
```

### 개발 계획
- **Phase 6**: YouTube 연동
- **예상 기간**: 2주
- **장점**: 문서화 우수, 테스트 용이

---

## 4. 넥슨 게임 연동 🎮

### 핵심 차별화 포인트!

**컨셉**: 게임 플레이 중 발생하는 이벤트를 실시간으로 방송 화면에 표시

### 예상 사용 시나리오

#### 메이플스토리
```
- 레벨업: "🎉 240레벨 달성!"
- 보스 처치: "💀 카오스 벨룸 격파! (3분 25초)"
- 레어 아이템 획득: "⭐ 앱솔랩스 완드 드롭!"
- 메소 획득: "💰 10억 메소 돌파!"
```

#### 던전앤파이터
```
- 장비 강화: "⚔️ +13 강화 성공!"
- 던전 클리어: "🏆 바칼 레이드 클리어!"
- 아이템 획득: "🎁 에픽 드롭!"
```

#### 카트라이더
```
- 레이스 승리: "🏁 1등 피니시!"
- 신기록: "⏱️ 개인 최고 기록 갱신!"
- 아이템 획득: "🎈 X 엔진 획득!"
```

### 기술적 연동 방식

#### Option 1: 넥슨 공식 API (이상적)
```javascript
// 가정: 넥슨이 게임 이벤트 API 제공
POST /webhooks/nexon
{
  "game": "maplestory",
  "event": "level_up",
  "player": {
    "id": "xxx",
    "name": "홍길동",
    "level": 240
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

#### Option 2: 로컬 클라이언트 (현실적)
```
┌─────────────────────────────────┐
│   게임 (메이플스토리)             │
│   - 게임 로그 파일 생성           │
│   - 또는 메모리 읽기              │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│  OBS Helper Client (로컬 앱)     │
│  - 게임 프로세스 모니터링         │
│  - 로그 파일 Tail                │
│  - 이벤트 파싱                   │
└────────────┬────────────────────┘
             │ WebSocket
┌────────────▼────────────────────┐
│  OBS Helper Server              │
│  - 이벤트 검증                   │
│  - 위젯으로 푸시                 │
└────────────┬────────────────────┘
             │ WebSocket
┌────────────▼────────────────────┐
│  OBS 위젯                        │
│  - "240레벨 달성!" 알림 표시     │
└─────────────────────────────────┘
```

#### Option 3: OBS 플러그인
```cpp
// OBS 플러그인으로 게임 메모리 읽기
obs_source_t* create_nexon_source() {
  // 게임 프로세스 찾기
  HANDLE hProcess = OpenProcess(PROCESS_VM_READ, FALSE, gameProcessId);

  // 메모리 주소에서 레벨 읽기
  int level;
  ReadProcessMemory(hProcess, levelAddress, &level, sizeof(level), NULL);

  // 변화 감지 → WebSocket으로 전송
  if (level != previousLevel) {
    sendEventToServer("level_up", level);
  }
}
```

### 데이터 구조

#### 게임 이벤트 스키마
```sql
CREATE TABLE game_events (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  game VARCHAR(100) NOT NULL, -- 'maplestory', 'dnf', 'kartrider'
  event_type VARCHAR(100) NOT NULL, -- 'level_up', 'boss_kill', 'item_drop'
  event_data JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 예시 데이터
{
  "game": "maplestory",
  "event_type": "level_up",
  "event_data": {
    "character": "홍길동",
    "from_level": 239,
    "to_level": 240,
    "job": "아크메이지(불,독)"
  }
}
```

#### 위젯 설정
```javascript
// 게임 이벤트 알림 위젯 설정
{
  "widget_type": "game_event",
  "game": "maplestory",
  "enabled_events": [
    "level_up",
    "boss_kill",
    "item_drop_epic",
    "item_drop_unique"
  ],
  "display_settings": {
    "duration": 5000,
    "animation": "slide_in",
    "sound": "level_up.mp3",
    "position": "top_right"
  }
}
```

### 개발 계획

#### Phase 1: 프로토타입 (4주)
- [ ] 게임 이벤트 파싱 연구
  - 메이플스토리 로그 파일 분석
  - 이벤트 추출 알고리즘
- [ ] 로컬 클라이언트 개발 (Electron or Go)
  - 게임 프로세스 감지
  - 로그 파일 Tail
  - 이벤트 파싱 및 전송
- [ ] 서버 연동
  - 게임 이벤트 수신 API
  - WebSocket으로 위젯에 푸시
- [ ] 게임 이벤트 알림 위젯

#### Phase 2: 다중 게임 지원 (각 2주)
- [ ] 메이플스토리
- [ ] 던전앤파이터
- [ ] 카트라이더
- [ ] 기타 넥슨 게임

#### Phase 3: 고도화 (지속)
- [ ] 넥슨 공식 파트너십 추진
- [ ] 공식 API 연동 (가능 시)
- [ ] 커스텀 게임 이벤트 정의
- [ ] 통계 및 분석

### 법적/윤리적 고려사항

**⚠️ 중요**: 게임 메모리 직접 읽기는 게임 이용약관 위반 가능

#### 안전한 접근 방식
1. **넥슨과 공식 파트너십**
   - 공식 API 제공 요청
   - 스트리머 지원 프로그램 참여

2. **게임 로그 파일 사용**
   - 공개된 로그 파일만 읽기
   - 메모리 직접 접근 지양

3. **사용자 명시적 동의**
   - "게임 데이터 읽기 권한" 명확한 안내
   - 선택적 기능 (필수 아님)

---

## 플랫폼 연동 우선순위 (최종)

### Phase 4: YouTube Live 연동 (2주) 🔴
**MVP 검증용 - API 확실, 문서화 우수**
- YouTube Data API v3 (검증된 API)
- Live Chat, 슈퍼챗, 구독 이벤트
- MVP 아키텍처 검증
- 글로벌 호환

### Phase 5: 치지직 연동 (3주) 🔴
**한국 시장 타겟 1순위**
- 네이버 플랫폼
- API 조사 완료 후 개발
- 빠르게 성장 중

### Phase 6: SOOP 연동 (2주) 🟡
**한국 최대 플랫폼**
- 별풍선 후원 시스템
- 팬가입 기능
- 안정적인 API

### Phase 7: 넥슨 게임 연동 (4주+) 🌟
**차별화 핵심 기능**
- 메이플스토리, 던파, 카트
- 프로토타입부터 시작
- 단계적 확장

### ⚠️ 제외: Twitch
- 한국 시장 집중을 위해 제외
- 리소스를 한국 플랫폼에 집중

---

## API 조사 체크리스트

### 치지직
- [ ] 개발자 콘솔 찾기
- [ ] API 문서 확인
- [ ] 테스트 계정 생성
- [ ] OAuth 플로우 테스트
- [ ] 이벤트 종류 파악
- [ ] Rate Limiting 확인

### SOOP
- [ ] https://developers.afreecatv.com 확인
- [ ] 아프리카도우미 분석
- [ ] 별풍선 API 조사
- [ ] 커뮤니티 포럼 조사

### YouTube
- [ ] Google Cloud Console 프로젝트 생성
- [ ] YouTube Data API v3 활성화
- [ ] OAuth 2.0 Credentials 생성
- [ ] Live Chat API 테스트

### 넥슨
- [ ] 넥슨 개발자 포털 확인
- [ ] 게임별 API 존재 여부
- [ ] 메이플스토리 로그 파일 위치 파악
- [ ] 합법적 데이터 수집 방법 연구
- [ ] 넥슨 비즈니스 개발팀 컨택

---

## 다음 단계

1. **API 조사 시작**
   - 치지직 API 문서 찾기
   - SOOP API 테스트
   - 넥슨 게임 데이터 수집 방법 연구

2. **프로토타입 개발**
   - 치지직 OAuth 테스트
   - 메이플스토리 로그 파일 파싱 POC

3. **커뮤니티 피드백**
   - 스트리머들에게 원하는 기능 조사
   - 특히 넥슨 게임 연동 니즈 파악
