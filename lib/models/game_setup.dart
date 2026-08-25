import 'game_outcome.dart';

/// 참가자 설정 화면들을 거쳐 모인 데이터. 게임의 computeResult/buildPlayScreen에
/// 그대로 전달된다.
class GameSetup {
  final List<String> participants;
  final List<GameOutcome> outcomes;

  const GameSetup({required this.participants, required this.outcomes});
}
