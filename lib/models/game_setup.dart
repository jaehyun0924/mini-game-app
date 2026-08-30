import 'game_outcome.dart';

/// 참가자 설정 화면들을 거쳐 모인 데이터. 게임의 computeResult/buildPlayScreen에
/// 그대로 전달된다.
///
/// [outcomes]와 [pickCount]는 둘 다 선택 항목이고, 게임마다 필요한 쪽만 쓴다.
/// - [outcomes]: 사다리타기/제비뽑기처럼 "슬롯 하나하나에 결과 라벨을 배정"하는
///   게임이 씀 (길이가 보통 참가자 수와 같다).
/// - [pickCount]: 로또뽑기처럼 "참가자 중 몇 명을 뽑을지"라는 개수만 필요한
///   게임이 씀. 라벨이 필요 없는 개수를 outcomes 더미 리스트로 흉내 내지
///   않도록 별도 필드로 뒀다.
/// - 룰렛/통아저씨/악어이빨처럼 참가자 입력 뒤 별도 설정이 아예 없는 게임은
///   둘 다 비워두면 된다 (MiniGame.playWithoutOutcomes 참고).
class GameSetup {
  final List<String> participants;
  final List<GameOutcome> outcomes;
  final int? pickCount;

  const GameSetup({
    required this.participants,
    this.outcomes = const [],
    this.pickCount,
  });
}
