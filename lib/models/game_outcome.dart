/// 게임 결과 하나 (예: 사다리 도착 지점, 룰렛 칸 등에 배정되는 값).
class GameOutcome {
  final String label;
  final bool isSpecial;

  const GameOutcome({required this.label, this.isSpecial = false});
}
