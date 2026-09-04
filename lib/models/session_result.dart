import 'game_outcome.dart';

/// 게임 한 판이 끝났을 때 참가자별로 어떤 결과를 받았는지 담는 값.
/// 게임 종류(사다리타기/룰렛/...)가 달라도 이 형태만 채우면 세션 저장과
/// 랭킹 집계가 게임과 무관하게 똑같이 동작한다.
class SessionResult {
  final Map<String, GameOutcome> outcomesByParticipant;

  const SessionResult(this.outcomesByParticipant);
}

/// 게임이 끝났을 때 호출되는 콜백. 그룹 없이(홈 화면에서 바로) 게임을 시작한
/// 경우에는 이 콜백 자체가 null이라 아무 것도 저장하지 않는다.
typedef GameResultCallback = Future<void> Function(SessionResult result);
