import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/common/shuffle_sequence.dart';

void main() {
  group('ShuffleSequence', () {
    test('itemCount가 1 이하면 항등 배치 2개만 반환한다', () {
      expect(
        ShuffleSequence.generate(itemCount: 0, stepCount: 5, random: Random(1)),
        [[], []],
      );
      expect(
        ShuffleSequence.generate(itemCount: 1, stepCount: 5, random: Random(1)),
        [
          [0],
          [0],
        ],
      );
    });

    test('stepCount가 2 이하면 itemCount와 무관하게 항등 배치 2개만 반환한다', () {
      final result = ShuffleSequence.generate(
        itemCount: 5,
        stepCount: 2,
        random: Random(1),
      );
      expect(result, [
        [0, 1, 2, 3, 4],
        [0, 1, 2, 3, 4],
      ]);
    });

    test('첫 단계와 마지막 단계는 항상 항등 배치다', () {
      for (var seed = 0; seed < 20; seed++) {
        final result = ShuffleSequence.generate(
          itemCount: 6,
          stepCount: 8,
          random: Random(seed),
        );
        final identity = List<int>.generate(6, (i) => i);
        expect(result.first, identity);
        expect(result.last, identity);
      }
    });

    test('단계 수만큼 배치를 생성한다', () {
      final result = ShuffleSequence.generate(
        itemCount: 6,
        stepCount: 8,
        random: Random(7),
      );
      expect(result.length, 8);
    });

    test('중간 배치는 모두 0~itemCount-1의 순열이다 (카드 정체성 보존)', () {
      for (var seed = 0; seed < 20; seed++) {
        final result = ShuffleSequence.generate(
          itemCount: 6,
          stepCount: 8,
          random: Random(seed),
        );
        for (final arrangement in result) {
          expect(arrangement.toSet(), {0, 1, 2, 3, 4, 5});
        }
      }
    });

    test('연속한 두 배치는 항상 서로 다르다 (제자리 셔플 없음)', () {
      for (var seed = 0; seed < 20; seed++) {
        final result = ShuffleSequence.generate(
          itemCount: 5,
          stepCount: 6,
          random: Random(seed),
        );
        for (var i = 1; i < result.length; i++) {
          expect(
            result[i],
            isNot(equals(result[i - 1])),
            reason: 'seed=$seed step=$i',
          );
        }
      }
    });

    test('아이템이 2개뿐이어도(순열이 2가지뿐이어도) 멈추지 않고 끝난다', () {
      final result = ShuffleSequence.generate(
        itemCount: 2,
        stepCount: 6,
        random: Random(3),
      );
      expect(result.length, 6);
      expect(result.first, [0, 1]);
      expect(result.last, [0, 1]);
    });
  });
}
