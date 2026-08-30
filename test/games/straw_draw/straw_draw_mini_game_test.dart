import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/straw_draw/straw_draw_mini_game.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/game_setup.dart';

void main() {
  group('StrawDrawMiniGame.computeResult', () {
    test('막대에 배정된 결과를 뒤섞을 뿐, 결과 목록 자체는 바뀌지 않는다', () {
      final game = StrawDrawMiniGame();
      final outcomes = const [
        GameOutcome(label: '당첨', isSpecial: true),
        GameOutcome(label: '통과'),
        GameOutcome(label: '통과'),
        GameOutcome(label: '통과'),
      ];
      final setup = GameSetup(
        participants: ['A', 'B', 'C', 'D'],
        outcomes: outcomes,
      );

      for (var seed = 0; seed < 20; seed++) {
        final result = game.computeResult(setup, Random(seed));

        expect(result.length, outcomes.length);
        expect(result.toSet(), outcomes.toSet());
        expect(result.where((o) => o.isSpecial).length, 1);
      }
    });
  });
}
