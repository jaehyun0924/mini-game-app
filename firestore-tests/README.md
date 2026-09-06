# Firestore 보안 규칙 테스트

`../firestore.rules`를 Firebase 로컬 에뮬레이터에 올려서 실제로 통과/거부되는지
확인하는 테스트다. Dart 코드가 아니라서 `flutter test`가 아니라 여기서 따로
Node.js로 돌린다.

## 준비물

- Java(JRE) — Firestore 에뮬레이터가 내부적으로 필요로 한다.
  없으면 `winget install EclipseAdoptium.Temurin.21.JRE`로 설치.
- Node.js (이미 설치돼 있다면 그대로 사용)

## 실행

```
cd firestore-tests
npm install   # 최초 1회
npm test
```

`npm test`는 `firebase emulators:exec`로 Firestore 에뮬레이터를 띄우고,
그 안에서 mocha 테스트를 돌린 뒤 자동으로 에뮬레이터를 종료한다. 콘솔에
보이는 `PERMISSION_DENIED` 로그는 "거부되는 게 맞는지" 확인하는
`assertFails()` 테스트가 의도적으로 거부당한 요청을 남긴 흔적이라 정상이다 —
mocha 결과의 `passing`/`failing` 개수만 보면 된다.

## 무엇을 검증하나

`users`/`groups`/`groups/{id}/sessions`/`inviteCodes`/`feedback` 및 그 외
컬렉션(catch-all)에 대해 파일별로 나눠서 검증한다:

- 그룹 멤버가 아니면 세션 읽기/쓰기, 그룹 임의 수정, 그룹 삭제가 모두 거부되는지
- 세션은 host 본인을 포함해 그 누구도 생성 후 수정/삭제할 수 없는지
  (결과 조작으로 내기에서 빠져나가는 걸 막는 핵심 규칙)
- 그룹 가입/탈퇴가 "정확히 자기 uid 하나만" 바꾸는 경우로만 제한되는지
- 방장만 그룹 삭제·초대 코드 재발급을 할 수 있는지
