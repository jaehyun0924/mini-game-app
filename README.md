# mini_game_app

연구실 점심/커피 내기용 미니게임 앱. 사다리타기·룰렛·제비뽑기·로또뽑기·통아저씨·악어이빨 등 미니게임 모음과 게임 결과 기록·랭킹 기능을 제공합니다.

## 기술 스택

- Front-end: Flutter + Dart
- Back-end: Firebase (Firestore + Auth)

## 시작하기

```bash
flutter pub get
flutter run -d chrome --web-port=8765
```

Windows 데스크톱 빌드는 Visual Studio C++ 워크로드가 필요해 현재는 Chrome으로 실행합니다.

## Firestore 보안 규칙 테스트

```bash
cd firestore-tests
npm install
npm test
```

로컬 Firebase 에뮬레이터로 `firestore.rules`를 검증합니다.

## 프로젝트 구조

```
lib/
  main.dart      # 앱 진입점, 라우팅
  screens/       # 화면 단위 위젯
  games/         # 게임별 로직+UI
  widgets/       # 여러 화면에서 재사용하는 공용 위젯
  theme/         # 색상, 폰트, 애니메이션 상수
  models/        # 데이터 모델 클래스
  services/      # Firebase 연동, 로컬 저장소 등 외부 연결 로직
```

자세한 작업 규칙은 [CLAUDE.md](./CLAUDE.md)를 참고하세요.
