/// 사다리 도착 지점(세로선)마다 배정되는 결과 하나.
class LadderOutcome {
  final String label;
  final bool isSpecial;

  const LadderOutcome({required this.label, this.isSpecial = false});
}
