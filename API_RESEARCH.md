# API 조사 계획

## 목표
각 플랫폼의 API를 조사하여 개발 가능성과 구현 방법을 파악

---

## 1. YouTube Live API 조사 (우선순위 1)

### 왜 YouTube 먼저?
- ✅ 공식 API 잘 문서화
- ✅ OAuth 2.0 완벽 지원
- ✅ 많은 예제 코드
- ✅ MVP 검증에 최적

### 조사 항목

#### 1.1 기본 설정
- [ ] Google Cloud Console 프로젝트 생성
- [ ] YouTube Data API v3 활성화
- [ ] YouTube Live Streaming API 활성화
- [ ] OAuth 2.0 Credentials 생성
- [ ] 테스트 계정 설정

#### 1.2 인증 (OAuth 2.0)
```javascript
// OAuth 2.0 Flow
1. Authorization URL 생성
   https://accounts.google.com/o/oauth2/v2/auth?
   client_id=xxx&
   redirect_uri=http://localhost:3000/callback&
   response_type=code&
   scope=https://www.googleapis.com/auth/youtube.readonly

2. Authorization Code 받기
3. Access Token 교환
4. Refresh Token 저장
```

**조사 포인트:**
- [ ] Scope 확인
  - `youtube.readonly` - 채널 정보 읽기
  - `youtube.force-ssl` - Live Chat 읽기
- [ ] Token 유효기간
- [ ] Refresh 방법

#### 1.3 실시간 이벤트 수신

**YouTube Live Chat API**
```javascript
// Polling 방식 (공식)
GET https://www.googleapis.com/youtube/v3/liveChat/messages
  ?liveChatId=xxx
  &part=snippet,authorDetails
  &key=xxx

// 5초마다 폴링
setInterval(async () => {
  const messages = await fetchNewMessages();
  // 새 메시지 처리
}, 5000);
```

**조사 포인트:**
- [ ] Live Chat ID 얻는 방법
- [ ] Polling 간격 (Rate Limit)
- [ ] 슈퍼챗 이벤트 구조
- [ ] 구독 이벤트 (PubSubHubbub?)

#### 1.4 지원 이벤트

**확인 필요:**
- [ ] 새 구독자 (New Subscriber)
  - API: Subscriptions.insert webhook?
  - PubSubHubbub 사용?
- [ ] 슈퍼챗 (Super Chat)
  - Live Chat Message type = `superChatEvent`
  - 금액, 메시지 포함
- [ ] 멤버십 가입 (Membership)
  - Live Chat Message type = `membershipItem`
- [ ] 채팅 메시지
  - Live Chat Messages API

#### 1.5 Rate Limiting
```
YouTube Data API v3:
- 기본 할당량: 10,000 units/day
- Live Chat Messages: 5 units per request

계산:
- 5초마다 폴링 = 12 req/min = 720 req/hour
- 720 req × 5 units = 3,600 units/hour
- 24시간 = 86,400 units (초과!)

해결책:
- Polling 간격 조정 (10초 or 15초)
- 할당량 증가 신청
```

**조사 포인트:**
- [ ] 실제 Rate Limit 측정
- [ ] 할당량 증가 신청 방법
- [ ] 에러 핸들링

### 1.6 구현 예제

```javascript
// YouTube Live Chat 수신 예제
import { google } from 'googleapis';

const youtube = google.youtube('v3');

// 1. OAuth 인증
const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URL
);

// 2. Live Broadcast 정보 얻기
const broadcasts = await youtube.liveBroadcasts.list({
  auth: oauth2Client,
  part: 'snippet',
  mine: true
});

const liveChatId = broadcasts.data.items[0].snippet.liveChatId;

// 3. Live Chat Polling
let nextPageToken = null;
setInterval(async () => {
  const response = await youtube.liveChatMessages.list({
    auth: oauth2Client,
    liveChatId: liveChatId,
    part: 'snippet,authorDetails',
    pageToken: nextPageToken
  });

  nextPageToken = response.data.nextPageToken;

  for (const message of response.data.items) {
    if (message.snippet.type === 'superChatEvent') {
      // 슈퍼챗 처리
      const amount = message.snippet.superChatDetails.amountMicros / 1000000;
      const user = message.authorDetails.displayName;

      // WebSocket으로 위젯에 전송
      io.to(widgetId).emit('event:donation', {
        platform: 'youtube',
        user,
        amount,
        message: message.snippet.superChatDetails.userComment
      });
    }
  }
}, 10000); // 10초마다
```

### 1.7 참고 문서
- [YouTube Data API](https://developers.google.com/youtube/v3)
- [Live Streaming API](https://developers.google.com/youtube/v3/live)
- [Live Chat Messages](https://developers.google.com/youtube/v3/live/docs/liveChatMessages)
- [OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)

---

## 2. 치지직 (CHZZK) API 조사 (우선순위 2)

### 왜 중요한가?
- 한국 시장 타겟 1순위
- 네이버 플랫폼 (신뢰성)
- 빠르게 성장 중

### 조사 항목

#### 2.1 개발자 포털 찾기
- [ ] https://developers.chzzk.naver.com 확인
- [ ] 네이버 개발자 센터 확인
- [ ] 공식 문서 존재 여부
- [ ] 커뮤니티 / 포럼

#### 2.2 API 존재 여부 확인
**확인 방법:**
1. 공식 웹사이트 검색
2. 네이버 개발자 센터 문의
3. 커뮤니티에서 정보 수집
4. 크롬 개발자 도구로 네트워크 분석

**예상 시나리오:**
- **Case 1**: 공식 API 존재
  - OAuth 방식 확인
  - Webhook/WebSocket 지원 확인
  - 이벤트 타입 파악

- **Case 2**: 공식 API 없음
  - Plan B: 크롬 익스텐션 방식
  - Plan C: 네이버 파트너십 문의
  - Plan D: YouTube로 MVP 완성 후 대기

#### 2.3 조사 체크리스트
- [ ] API 문서 URL
- [ ] 개발자 등록 방법
- [ ] 인증 방식 (OAuth 2.0?)
- [ ] 실시간 이벤트 수신 방식
  - [ ] WebHook
  - [ ] WebSocket
  - [ ] Polling
- [ ] 지원 이벤트
  - [ ] 팔로우
  - [ ] 구독 (후원?)
  - [ ] 채팅
  - [ ] 도네이션
- [ ] Rate Limiting
- [ ] 샘플 코드

#### 2.4 대체 방안 (API 없을 경우)

**크롬 익스텐션 방식:**
```javascript
// content_script.js (치지직 웹페이지에 주입)
window.addEventListener('message', (event) => {
  if (event.data.type === 'CHZZK_FOLLOW') {
    // 서버로 전송
    fetch('https://obs-helper.com/api/events/chzzk', {
      method: 'POST',
      body: JSON.stringify(event.data)
    });
  }
});

// 치지직 웹페이지의 WebSocket 감청
const originalWebSocket = window.WebSocket;
window.WebSocket = function(...args) {
  const ws = new originalWebSocket(...args);
  ws.addEventListener('message', (event) => {
    // 이벤트 파싱 및 전송
  });
  return ws;
};
```

---

## 3. SOOP (아프리카TV) API 조사 (우선순위 3)

### 조사 항목

#### 3.1 공식 API 확인
- [ ] https://developers.afreecatv.com 확인
- [ ] API 문서 읽기
- [ ] 개발자 등록

#### 3.2 조사 체크리스트
- [ ] 인증 방식
- [ ] 별풍선 (스티커) API
- [ ] 팬가입 API
- [ ] 채팅 API
- [ ] WebHook 지원 여부
- [ ] Rate Limiting

#### 3.3 참고
- [ ] 아프리카도우미 분석
- [ ] 커뮤니티에서 정보 수집

---

## 4. 넥슨 게임 API 조사 (우선순위 4)

### 조사 항목

#### 4.1 넥슨 개발자 포털
- [ ] https://developers.nexon.com 확인
- [ ] 게임별 API 존재 여부
- [ ] 파트너 프로그램

#### 4.2 메이플스토리 데이터 수집 방법

**Option 1: 공식 API (이상적)**
- [ ] 메이플스토리 API 존재 여부
- [ ] 캐릭터 정보 API
- [ ] 플레이 로그 API

**Option 2: 로그 파일 (현실적)**
```
조사 항목:
- [ ] 로그 파일 위치
  - Windows: C:\Nexon\MapleStory\
  - 로그 파일명: ?
- [ ] 로그 형식
  - 레벨업 이벤트 포맷
  - 보스 처치 이벤트 포맷
  - 아이템 드롭 이벤트 포맷
- [ ] 실시간 tail 가능 여부
```

**Option 3: 메모리 읽기 (리스크)**
```
⚠️ 법적 리스크:
- 게임 메모리 직접 접근은 이용약관 위반 가능
- 치트/핵 프로그램으로 오인될 수 있음
- 넥슨 공식 파트너십 없이는 권장하지 않음

권장 접근:
1. 넥슨에 공식 문의
2. 파트너십 프로그램 신청
3. 합법적 방법만 사용
```

#### 4.3 법적/윤리적 검토
- [ ] 넥슨 이용약관 검토
- [ ] 게임 데이터 사용 가능 범위
- [ ] 비즈니스 개발팀 컨택 방법

---

## 조사 일정

### Week 1: YouTube API (2-3일)
- Day 1: 문서 읽기, 개발 환경 설정
- Day 2: OAuth 테스트, Live Chat 수신 테스트
- Day 3: 슈퍼챗, 구독 이벤트 테스트

### Week 1: 치지직 API (2-3일)
- Day 1: 개발자 포털 찾기
- Day 2: API 문서 분석 (있을 경우)
- Day 3: 대체 방안 검토 (없을 경우)

### Week 1: SOOP API (1-2일)
- Day 1: 공식 API 확인
- Day 2: 테스트 계정 생성 및 간단한 테스트

### Week 2: 넥슨 게임 (2-3일)
- Day 1: 넥슨 개발자 포털 조사
- Day 2: 메이플스토리 로그 파일 분석
- Day 3: 법적 검토 및 공식 파트너십 문의

---

## 조사 결과 정리 템플릿

각 플랫폼 조사 완료 후 다음 형식으로 정리:

```markdown
# [플랫폼명] API 조사 결과

## 요약
- API 존재: Yes/No
- 개발 가능: Yes/No/Conditional
- 권장 접근: [방법]

## 인증
- 방식: OAuth 2.0 / API Key / 기타
- 등록 방법: [URL 및 절차]

## 이벤트 수신
- 방식: WebHook / WebSocket / Polling
- 지원 이벤트: [목록]

## 제약사항
- Rate Limit: [수치]
- 기타 제약: [내용]

## 샘플 코드
[코드]

## 추천 구현 방법
[설명]
```

---

## 다음 단계

조사 완료 후:
1. 각 플랫폼별 구현 난이도 평가
2. MVP 우선순위 최종 결정
3. 프로젝트 구조 생성 시작
