# Firestore 데이터 모델 (3단계: 기록·랭킹)

3단계 "기록·랭킹 시스템"에서 쓸 Firestore 컬렉션 구조. 실제 컬렉션/필드를 만들기 전에
먼저 문서로 정리해서, 나중에 스키마가 코드 여기저기 흩어져서 파악하기 어려워지는 걸
막는다.

## 컬렉션 구조

```
users/{uid}
  - nickname: string
  - createdAt: timestamp

groups/{groupId}
  - name: string
  - inviteCode: string        (6자리 랜덤 문자열, 사람이 남에게 불러줄 코드)
  - ownerId: string           (uid)
  - memberIds: string[]       (uid 목록, 그룹 만든 사람도 포함)
  - createdAt: timestamp

groups/{groupId}/sessions/{sessionId}
  - gameType: string          (예: "ladder", "roulette")
  - participants: string[]    (그 판에 참여한 사람 이름 또는 uid)
  - result: map                (게임별로 형태가 다른 결과 데이터)
  - hostId: string            (그 판을 실행한 사람의 uid)
  - createdAt: timestamp

inviteCodes/{code}
  - groupId: string
```

## 설계 이유

**sessions를 groups의 하위 컬렉션으로 둔 이유**
랭킹 조회는 항상 "특정 그룹 안에서"만 이뤄진다 (전체 앱 통합 랭킹 같은 건 없음). 최상위
컬렉션으로 두고 `where('groupId', '==', ...)`로 필터링할 수도 있지만, 하위 컬렉션으로
두면:
- 쿼리가 항상 `groups/{groupId}/sessions`로 시작해서 자연히 그룹 범위로 좁혀짐
- 보안 규칙도 "이 세션이 속한 groupId의 멤버인가"만 확인하면 되서 단순해짐 (최상위였다면
  세션 문서 자체에 groupId를 신뢰할 수 있게 박아두고 규칙에서 매번 참조해야 함)

**inviteCodes를 별도 컬렉션으로 둔 이유**
"6자리 코드로 그룹 찾기"를 `groups`에서 `where('inviteCode', '==', code)` 쿼리로 하면
문서가 많아질수록 느려지고, 인덱스도 신경 써야 한다. `inviteCodes/{code}` 문서 하나를
직접 `get()`하면 코드 자체가 문서 ID라서 조회가 항상 O(1)이다. `groups.inviteCode`
필드는 그룹 문서 안에서 "내 초대 코드가 뭐였지" 보여줄 때 쓰고, 실제 코드→그룹 찾기는
`inviteCodes` 컬렉션이 담당한다.

## 보안 규칙 초안 (firestore.rules)

- `users/{uid}`: 로그인한 사람이면 누구나 읽을 수 있음(그룹 멤버 목록에 닉네임을 보여줘야
  해서). 쓰기는 본인 uid 문서만 가능.
- `groups/{groupId}`: 멤버(`memberIds`에 uid 포함)만 읽고 수정할 수 있음. 생성은
  "만드는 사람이 곧 owner이자 유일한 초기 멤버"인 경우만 허용.
- `groups/{groupId}/sessions/{sessionId}`: 그룹 멤버만 읽을 수 있고, 생성은 `hostId`가
  본인 uid일 때만 허용. 기록은 남긴 뒤 수정/삭제하지 않는 걸 전제로 update/delete는 막아둠.
- `inviteCodes/{code}`: 로그인한 사람이면 읽을 수 있음(코드로 그룹을 찾아야 하니까).
  쓰기는 지금 단계에서는 전부 막아둠 — "그룹 만들기/초대 코드로 참가하기" 화면을 실제로
  구현할 때(다음 목표) `groups` 생성과 원자적으로 같이 처리해야 해서, 그때 클라이언트
  규칙으로 열지 Cloud Function으로 처리할지 다시 정한다.

## 지금은 안 정한 것

- `sessions.result`의 구체적인 필드 형태 (게임마다 다를 수 있음) — 실제로 기록을
  저장하는 코드를 짤 때 게임별로 정리
- 그룹 생성/초대 코드 참가 플로우 자체 — 이번 목표(#1)는 데이터 모델과 인증까지만,
  플로우는 다음 목표에서 화면과 함께 구현
