import 'dart:math';

/// 룰렛 회전각 계산을 담당하는 순수 함수 모음. 위젯 상태와 분리해서
/// 유닛 테스트로 각도 계산이 맞는지 검증할 수 있게 한다.
///
/// 각도 기준: 0 = 12시(포인터 고정 위치), 양의 각도 = 시계방향.
/// Flutter 캔버스는 y축이 아래로 증가해서 canvas.rotate(양수)가 실제로도
/// 시계방향으로 보이므로, 이 기준을 그대로 canvas.rotate에 넘기면 된다.
class RouletteAngles {
  const RouletteAngles._();

  /// 섹터 하나가 차지하는 중심각.
  static double sectorAngle(int sectorCount) => 2 * pi / sectorCount;

  /// winningIndex번째 섹터의 중심이 포인터(12시, 절대각 0) 아래 오도록,
  /// currentRotation(이전 스핀이 끝난 누적 회전각)에서 이어서 최소
  /// extraTurns바퀴 이상 시계방향으로 돌고 멈추는 최종 회전각을 계산한다.
  ///
  /// 섹터 k 중심이 포인터와 겹치는 조건은
  /// (k+0.5)*sectorAngle + R ≡ 0 (mod 2π) 이므로 R ≡ -(k+0.5)*sectorAngle.
  /// Dart의 % 연산자는 항상 [0, divisor) 범위의 비음수를 반환하므로(Euclidean
  /// modulo), 아래 계산에는 별도의 음수 보정이 필요 없다 — 대신 부호가
  /// 피제수를 따라가는 remainder()는 여기서 쓰면 안 된다.
  static double computeTargetRotation({
    required double currentRotation,
    required int winningIndex,
    required int sectorCount,
    int extraTurns = 4,
  }) {
    final angle = sectorAngle(sectorCount);
    final desiredMod = (2 * pi - (winningIndex + 0.5) * angle) % (2 * pi);
    final currentMod = currentRotation % (2 * pi);
    final deltaToAlign = (desiredMod - currentMod) % (2 * pi);
    return currentRotation + deltaToAlign + extraTurns * 2 * pi;
  }
}
