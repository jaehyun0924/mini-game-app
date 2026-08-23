# CLAUDE.md

이 파일은 Claude Code가 이 프로젝트에서 작업할 때 항상 참고하는 규칙입니다. 코드 자체가 아니라 "어떻게 작업해야 하는가"를 적어두는 문서입니다.

## 프로젝트 개요

연구실 점심/커피 내기용 미니게임 앱. 사다리타기·룰렛·제비뽑기·로또뽑기·통아저씨·악어이빨 등 미니게임 모음 + 게임 결과 기록·랭킹. 토스 스타일의 부드러운 애니메이션이 차별점.

1인 개발, Claude Code와 협업. 개발자는 Flutter/Dart를 이제 막 배운 초보자이므로, 복잡한 코드를 작성할 때는 왜 그렇게 짰는지 짧게 설명을 남겨줄 것.

## 기술 스택

- Front-end: Flutter + Dart
- Back-end: Firebase (Firestore + Auth + Cloud Functions) — 3단계(기록/랭킹)부터 실제 연동 시작
- 상태 관리: 현재는 `setState` 기반. Provider/Riverpod 등 도입 여부는 미정 (아래 "아직 정하지 않은 것" 참고)

## 폴더 구조

```
lib/
  main.dart              # 앱 진입점, 라우팅만
  screens/                # 화면 단위 위젯 (예: home_screen.dart, ladder_screen.dart)
  games/                  # 게임별 로직+UI (예: games/ladder/, games/roulette/)
  widgets/                # 여러 화면에서 재사용하는 공용 위젯 (버튼, 카드 등)
  theme/                  # 색상, 폰트, 텍스트 스타일, 공통 애니메이션 duration/curve 상수
  models/                 # 데이터 모델 클래스 (게임 결과, 사용자 등)
  services/               # Firebase 연동, 로컬 저장소 등 외부 연결 로직
```

새 게임을 추가할 때는 `lib/games/<게임이름>/` 아래에 그 게임 전용 파일을 모아둔다. 여러 게임에서 공통으로 쓰는 위젯만 `lib/widgets/`로 뺀다.

## 네이밍 규칙

- 파일명: `snake_case.dart` (예: `ladder_screen.dart`, `shrink_button.dart`)
- 클래스명: `PascalCase` (예: `LadderScreen`, `ShrinkButton`)
- 변수/함수명: `camelCase`, private은 `_camelCase`
- State 클래스는 관례대로 `_위젯이름State` (예: `_ShrinkButtonState`)

## 색상 / 폰트 / 애니메이션 상수

토스 스타일의 일관된 느낌을 위해, 색상·폰트·애니메이션 duration/curve 값을 화면 코드에 직접 쓰지 않고 `lib/theme/`에 상수로 정의해서 가져다 쓴다.

- `lib/theme/colors.dart` — 앱 전체 색상 팔레트
- `lib/theme/text_styles.dart` — 텍스트 스타일 프리셋
- `lib/theme/motion.dart` — 공용 애니메이션 duration/curve 상수 (예: `kPressDuration`, `kBounceCurve`) — 버튼 눌림 효과처럼 여러 위젯에서 반복될 애니메이션 값은 여기서 관리해서 게임마다 느낌이 달라지지 않게 한다.

## Git / 커밋 컨벤션

- 기본 브랜치: `main`. 1인 개발이라 별도 브랜치 전략 없이 `main`에 직접 커밋해도 무방.
- 커밋 메시지: 무엇을 했는지 한 줄로 (예: `사다리타기 화면 기본 레이아웃 추가`, `타이머 저장 버그 수정`). 완벽한 컨벤션(Conventional Commits 등)은 아직 요구하지 않음.
- 기능 단위로 자주 커밋할 것 — 한 커밋에 여러 기능 섞지 않기.

## Claude Code 작업 시 지켜야 할 규칙

- 한 번에 여러 기능을 몰아서 구현하지 말고, 기능 단위로 쪼개서 하나씩 진행하고 확인받을 것.
- 코드를 수정하면 그 의도를 짧게 설명할 것 (특히 `AnimationController`, `Tween`처럼 처음 보는 개념이 등장할 때).
- 실행 가능하면 직접 `flutter run`으로 확인하고, 에러가 나면 원인을 설명한 뒤 고칠 것.
- 웹으로 테스트할 때는 포트를 고정해서 실행할 것 (`--web-port=8765` 등) — 포트가 바뀌면 로컬 저장 데이터(localStorage)가 안 보이는 문제가 있었음.
- Windows 데스크톱 빌드는 Visual Studio C++ 워크로드 미설치 상태이므로, 별도 요청 없으면 Chrome으로 실행할 것.

## 로드맵 (현재 위치 참고용)

0. 기초 학습 (완료)
1. **← 현재 단계**: 첫 게임 프로토타입 (사다리타기 1개, 완성도 있게)
2. 게임 확장 (룰렛 등 5개 게임 추가 + 모듈화)
3. 기록·랭킹 시스템 (Firebase 연동, 그룹 기능)
4. 폴리싱 & 베타 (연구실 실사용 테스트)
5. 스토어 출시
6. 수익화 & 성장

지금은 1단계이므로, 2단계 이후에 필요한 것(여러 게임 간 공통 인터페이스 설계, Firebase 스키마 등)을 미리 과하게 설계하지 말 것. 딱 지금 필요한 만큼만 구현.

## 아직 정하지 않은 것 (미리 결정하지 말고, 필요해질 때 다시 논의)

- 상태 관리 라이브러리 도입 여부 (Provider/Riverpod 등) — 게임이 늘어나서 `setState`로 감당 안 될 때 다시 검토
- Firebase Firestore 데이터 구조 — 3단계에서 실제 필요해질 때 설계
- 테스트 코드 작성 전략 (unit/widget test) — 지금은 요구하지 않음, 폴리싱 단계에서 검토
- 다국어 지원, 접근성(a11y) — 스토어 출시 전 단계에서 검토
- CI/CD, 자동 빌드 — 필요 시점에 논의





## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---