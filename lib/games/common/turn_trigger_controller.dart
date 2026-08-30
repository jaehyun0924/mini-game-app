/// 턴제 트리거 게임(통아저씨, 악어이빨 등)의 진행 상태를 관리하는 공용
/// 컨트롤러. 슬롯 하나가 눌릴 때마다 [press]를 호출해서 트리거 여부를
/// 판정하고 턴을 넘긴다 — 화면을 그리는 책임은 없고 "누가 다음 차례인지,
/// 언제 끝났는지"만 계산해서 게임마다 다른 연출 위에서 재사용할 수 있게 한다.
class TurnTriggerController {
  final List<String> participants;
  final int triggerIndex;

  final Set<int> pressedIndices = {};
  int turnIndex = 0;
  bool triggered = false;

  TurnTriggerController({required this.participants, required this.triggerIndex});

  /// 현재 차례인 참가자. 트리거가 발동한 뒤에는 턴을 넘기지 않으므로,
  /// 트리거를 누른 바로 그 참가자를 계속 가리킨다.
  String get currentParticipant => participants[turnIndex % participants.length];

  /// index를 눌렀을 때의 결과를 반영한다. 트리거였으면 게임을 종료하고
  /// true를 반환하며, 아니었으면 다음 참가자로 턴을 넘기고 false를 반환한다.
  bool press(int index) {
    pressedIndices.add(index);
    final isTrigger = index == triggerIndex;
    if (isTrigger) {
      triggered = true;
    } else {
      turnIndex++;
    }
    return isTrigger;
  }
}
