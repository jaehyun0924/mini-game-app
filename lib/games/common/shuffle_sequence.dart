import 'dart:math';

/// 셔플 애니메이션의 중간 배치들을 계산하는 순수 함수. 위젯 상태와 분리해서
/// "카드가 어느 자리로 움직이는지"를 애니메이션 코드 없이도 검증할 수 있게 한다.
///
/// 반환값 arrangements에서 arrangements[s][cardIndex] = 그 단계(s)에서
/// cardIndex번 카드가 차지하는 화면 슬롯 번호. 첫 단계와 마지막 단계는 항상
/// 항등 배치(자기 슬롯 그대로)라서, 카드는 항상 제자리에서 출발해 제자리로
/// 돌아온다 — 카드의 "정체성"(index)과 화면 위치는 셔플 도중에만 갈라졌다가
/// 끝나면 다시 합쳐진다.
class ShuffleSequence {
  const ShuffleSequence._();

  static List<List<int>> generate({
    required int itemCount,
    required int stepCount,
    required Random random,
  }) {
    final identity = List<int>.generate(itemCount, (i) => i);
    if (itemCount <= 1 || stepCount <= 2) {
      return [identity, identity];
    }

    final arrangements = <List<int>>[identity];
    for (var s = 1; s < stepCount - 1; s++) {
      List<int> next;
      do {
        next = List<int>.of(identity)..shuffle(random);
      } while (_isSame(next, arrangements.last));
      arrangements.add(next);
    }
    arrangements.add(identity);
    return arrangements;
  }

  static bool _isSame(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
