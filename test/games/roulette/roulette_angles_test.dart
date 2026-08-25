import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/roulette/roulette_angles.dart';

/// angle을 (-pi, pi] 범위로 접어서, "목표 각도와 얼마나 어긋났는지"를
/// 부호 있는 값으로 비교하기 쉽게 만든다.
double _wrapToPi(double angle) {
  final wrapped = angle % (2 * pi);
  return wrapped > pi ? wrapped - 2 * pi : wrapped;
}

void main() {
  group('RouletteAngles', () {
    test('sectorAngle은 2π를 섹터 수로 나눈 값이다', () {
      expect(RouletteAngles.sectorAngle(4), closeTo(pi / 2, 1e-9));
      expect(RouletteAngles.sectorAngle(8), closeTo(pi / 4, 1e-9));
    });

    test('계산된 회전각으로 돌리면 당첨 섹터 중심이 항상 포인터(12시)와 정렬된다', () {
      for (var sectorCount = 2; sectorCount <= 8; sectorCount++) {
        final angle = RouletteAngles.sectorAngle(sectorCount);
        for (var winningIndex = 0; winningIndex < sectorCount; winningIndex++) {
          for (final currentRotation in [0.0, 1.234, 3 * 2 * pi, 10.0]) {
            final target = RouletteAngles.computeTargetRotation(
              currentRotation: currentRotation,
              winningIndex: winningIndex,
              sectorCount: sectorCount,
            );

            // 섹터 중심이 포인터(절대각 0)와 겹치는 조건:
            // (winningIndex+0.5)*angle + target ≡ 0 (mod 2π)
            final misalignment = _wrapToPi(
              (winningIndex + 0.5) * angle + target,
            );
            expect(
              misalignment.abs(),
              lessThan(1e-9),
              reason:
                  'sectorCount=$sectorCount winningIndex=$winningIndex '
                  'currentRotation=$currentRotation',
            );
          }
        }
      }
    });

    test('항상 정방향으로 최소 extraTurns바퀴 이상 돈다', () {
      const extraTurns = 4;
      for (final currentRotation in [0.0, 1.234, 3 * 2 * pi, 10.0]) {
        final target = RouletteAngles.computeTargetRotation(
          currentRotation: currentRotation,
          winningIndex: 2,
          sectorCount: 6,
          extraTurns: extraTurns,
        );

        final delta = target - currentRotation;
        expect(delta, greaterThanOrEqualTo(extraTurns * 2 * pi - 1e-9));
        // deltaToAlign은 [0, 2π) 범위이므로 여분 회전을 한 바퀴 넘게
        // 초과하지는 않는다.
        expect(delta, lessThan((extraTurns + 1) * 2 * pi + 1e-9));
      }
    });

    test('같은 섹터를 연달아 선택해도 매번 정방향으로 돈다(제자리에 멈춰있지 않음)', () {
      var currentRotation = 0.0;
      for (var i = 0; i < 5; i++) {
        final target = RouletteAngles.computeTargetRotation(
          currentRotation: currentRotation,
          winningIndex: 1,
          sectorCount: 4,
        );
        expect(target, greaterThan(currentRotation));
        currentRotation = target % (2 * pi);
      }
    });
  });
}
