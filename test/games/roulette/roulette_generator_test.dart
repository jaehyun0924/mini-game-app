import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/roulette/roulette_generator.dart';

void main() {
  group('RouletteGenerator', () {
    test('항상 유효한 참가자 인덱스를 뽑는다', () {
      for (var seed = 0; seed < 30; seed++) {
        final winner = RouletteGenerator.generate(
          participantCount: 5,
          random: Random(seed),
        );
        expect(winner, greaterThanOrEqualTo(0));
        expect(winner, lessThan(5));
      }
    });

    test('최소 인원(2명)에서도 유효한 인덱스를 뽑는다', () {
      final winner = RouletteGenerator.generate(
        participantCount: 2,
        random: Random(1),
      );
      expect(winner, anyOf(0, 1));
    });

    test('참가자가 2명 미만이면 예외를 던진다', () {
      expect(
        () => RouletteGenerator.generate(participantCount: 1),
        throwsArgumentError,
      );
    });

    test('참가자가 최대 인원(8명)을 초과하면 예외를 던진다', () {
      expect(
        () => RouletteGenerator.generate(participantCount: 9),
        throwsArgumentError,
      );
    });

    test('여러 번 뽑으면 모든 참가자가 골고루 당첨될 수 있다', () {
      final seen = <int>{};
      for (var seed = 0; seed < 200; seed++) {
        seen.add(
          RouletteGenerator.generate(participantCount: 4, random: Random(seed)),
        );
      }
      expect(seen, {0, 1, 2, 3});
    });
  });
}
