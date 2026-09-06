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
  - gameType: string          (MiniGame.id, 예: "ladder", "roulette")
  - participants: string[]    (그 판에 참여한 사람 이름)
  - result: map<string, map>  (참가자 이름 -> { label: string, isSpecial: bool })
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
- `groups/{groupId}`: 읽기는 로그인한 사람이면 누구나 가능(참여하기 전에 "이미
  가입된 그룹인지" 확인하려면 멤버가 아닌 사람도 그룹 문서를 읽을 수 있어야 함 —
  그룹 이름/멤버 목록은 users 프로필 닉네임처럼 로그인한 사람 전체에 공개된
  정보 수준으로 취급). 생성은 "만드는 사람이 곧 owner이자 유일한 초기 멤버"인
  경우만 허용. 수정(update)은 아래 세 가지 정확한 변경만 허용 — 멤버이기만
  하면 필드 제한 없이 아무 값이나 바꿀 수 있게 열어두면, 아무 멤버나 그룹
  이름·ownerId·memberIds를 통째로 바꿔치기할 수 있어서 case별로 좁혀뒀다.
  삭제(delete)는 방장만 가능.
- `groups/{groupId}/sessions/{sessionId}`: 그룹 멤버만 읽을 수 있고, 생성은 `hostId`가
  본인 uid일 때만 허용. 기록은 남긴 뒤 방장을 포함해 그 누구도 수정/삭제할 수
  없다(update/delete 항상 거부) — 진 사람이 자기 결과를 몰래 바꾸거나 지워서
  내기에서 빠져나가는 걸 막기 위한 핵심 규칙이다.
- `inviteCodes/{code}`: 로그인한 사람이면 읽을 수 있음(코드로 그룹을 찾아야 하니까).
  생성은 규칙에서 `get()`으로 이 code가 가리키는 `groupId`의 `ownerId`가 요청자
  본인인지 확인해서 남의 그룹에 코드를 심는 걸 막는다(Cloud Function 없이
  클라이언트 규칙만으로 처리). 그래서 클라이언트는 `groups` 문서를 먼저 만들고
  그 그룹이 실제로 존재하는 상태에서 `inviteCodes` 문서를 뒤이어 만든다 —
  WriteBatch로 한 번에 묶으면 규칙의 `get()`이 같은 batch 안의 그룹 생성을 아직
  없는 것으로 평가해 오히려 거부된다(batch 안의 쓰기끼리는 서로 안 보임). 코드는
  문서 ID라서 이미 존재하면 자동으로 create가 아닌 update로 취급되어 막히므로
  별도 중복 체크 규칙이 필요 없다. 삭제는 코드 재발급 때 기존 코드를 무효화하는
  용도로만 쓰며, 그 코드가 가리키는 그룹의 방장만 가능.
- `groups/{groupId}` 참여(초대 코드로 join): 아직 멤버가 아닌 로그인 사용자가
  `memberIds`에 자기 uid 하나만 추가하는 update는 허용한다. 다른 필드를 같이
  바꾸거나 남을 추가/제거하려는 요청은 막는다.
- `groups/{groupId}` 탈퇴(leave): 이미 멤버인 사용자가 `memberIds`에서 자기 uid
  하나만 빼는 update는 허용한다. 방장(ownerId)은 탈퇴할 수 없다 — 소유권 이전
  기능이 없는 상태에서 방장이 나가버리면 아무도 그룹을 못 지우는 상태가 되므로,
  방장은 "탈퇴"가 아니라 "그룹 삭제"로만 그룹을 떠날 수 있다.
- `groups/{groupId}` 삭제(delete): 방장만 가능. `sessions` 하위 컬렉션과
  `inviteCodes` 문서는 그룹 문서와 함께 자동으로 연쇄 삭제되지 않고 그대로
  남는다 — 대신 그룹 문서가 없으면 `sessions` 규칙의 `isMember()`가 `get()`에서
  실패해 아무도 못 읽는 고아 데이터가 되고, 남아있는 `inviteCodes` 문서로
  참여를 시도해도 `joinByCode()`가 "존재하지 않는 그룹"으로 처리해서 안전하게
  막는다. 연구실 소규모 그룹 앱 규모에서 Cloud Functions로 연쇄 삭제를 따로
  구현하는 비용보다 이 트레이드오프(고아 문서가 DB에 남는 것)가 더 낫다고
  판단했다.
- `groups/{groupId}` 초대 코드 재발급: 방장만 `inviteCode` 필드 하나만 새 값으로
  바꿀 수 있다. 실제 코드 문서 교체(기존 `inviteCodes/{oldCode}` 삭제 + 새
  `inviteCodes/{newCode}` 생성)는 각각 `inviteCodes` 규칙에서 독립적으로 검사한다.

## sessions.result 형태 (3단계에서 확정)

`result`는 참가자 이름을 키로 하는 map이고, 값은 그 참가자가 받은 결과 하나
(`GameOutcome`을 그대로 직렬화한 형태)다.

```
result: {
  "김재현": { "label": "커피 사기", "isSpecial": true },
  "이몽룡": { "label": "생존", "isSpecial": false }
}
```

- `isSpecial`이 랭킹의 "승/패" 판정 기준이다 — true를 받은 참가자를 그 판의
  "패"로, 나머지를 "승"으로 센다 (RankingEntry.winCount = playedCount - specialCount).
- 사다리타기/제비뽑기처럼 참가자가 직접 결과 라벨을 입력하는 게임은 그 라벨을
  그대로 쓰고, 룰렛/로또뽑기/통아저씨/악어이빨처럼 라벨 입력이 없는 게임은
  "당첨"/"통과" 또는 "커피 사기"/"생존" 같은 고정 라벨을 각 결과 화면에서
  붙인다.
- 어느 시점에 결과가 "확정"되는지는 게임마다 다르다: 사다리타기/제비뽑기/
  룰렛/로또뽑기는 컴퓨터가 이미 계산해둔 결과를 화면이 순서대로 보여주기만
  하므로 그 reveal이 끝나는 시점에 기록하고, 통아저씨/악어이빨은 실제로
  누가 트리거를 누르는지가 상호작용으로 정해지므로 트리거가 발동하는
  시점에 기록한다.

## 참가자 이름과 uid

`participants`/`result`의 키는 uid가 아니라 게임 시작할 때 자유 입력한
이름이다. 그룹원 개개인과 uid로 연결돼 있지 않으므로, "내 통계" 같은 화면은
로그인한 사용자의 닉네임과 문자열이 같은 참가자 이름을 자신의 기록으로
간주한다 — 그룹원들이 본인 닉네임을 그대로 입력해서 게임한다는 전제의 단순한
방식이다.

## 엣지 케이스: 게임 진행 중 참가자/그룹 구성이 바뀌는 경우

`participants`는 [ParticipantSetupScreen](../lib/games/common/participant_setup_screen.dart)에서
"다음"을 누르는 순간 그 시점의 이름 목록으로 스냅샷을 떠서 게임 화면에
넘기고, 게임이 끝나면 그 스냅샷 그대로 `recordSession`에 실려 나간다. 즉
게임은 한 기기에서 로컬로 진행되고 참가자 명단은 시작 시점에 고정되므로,
"게임 도중 누가 목록에서 빠진다" 같은 상황 자체가 UI상 발생하지 않는다
(참가자 추가/삭제는 전부 "다음"을 누르기 전 설정 화면에서만 가능).

다만 실제로 일어날 수 있는 시나리오는 하나 있다: 방장이 그룹 멤버인 상태로
게임을 시작한 뒤, 게임이 끝나기 전에 다른 기기에서 그 그룹을 탈퇴하거나
그룹 자체가 삭제되는 경우다. 이때 게임이 끝나 `recordSession`이 세션 문서를
`create`하려 하면 보안 규칙의 `isMember(groupId)` 조건을 더 이상 만족하지
못해 쓰기가 거부된다. 이는 버그가 아니라 의도된 동작이다 — 이미 그룹을
떠난 사람의 게임 기록이 그 그룹에 남는 게 오히려 이상하다. 클라이언트는
[game_result_recorder.dart](../lib/games/common/game_result_recorder.dart)에서
저장 실패 시 "기록 저장에 실패했어요" 스낵바 + 재시도 버튼을 보여주는데,
이 경우 재시도해도 계속 실패하며 그 판의 기록은 저장되지 않은 채로 남는다
(참가자들이 직접 진 사람을 가려낸 결과이므로, 굳이 로컬에 임시 저장하는
등의 추가 처리는 하지 않는다).
