import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/lotto_draw/lotto_mini_game.dart';
import 'package:mini_game_app/models/game_setup.dart';

void main() {
  group('LottoDrawMiniGame.computeResult', () {
    final participants = ['A', 'B', 'C', 'D', 'E'];

    test('pickCount 명만큼, 참가자 중에서 중복 없이 뽑는다', () {
      final game = LottoDrawMiniGame();
      final setup = GameSetup(participants: participants, pickCount: 3);

      for (var seed = 0; seed < 20; seed++) {
        final result = game.computeResult(setup, Random(seed));

        expect(result.length, 3);
        expect(result.toSet().length, 3, reason: '중복 당첨자가 없어야 한다');
        expect(participants.toSet().containsAll(result), isTrue);
      }
    });

    test('여러 번 뽑으면 모든 참가자가 골고루 당첨될 수 있다', () {
      final game = LottoDrawMiniGame();
      final setup = GameSetup(participants: participants, pickCount: 1);

      final seen = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        seen.addAll(game.computeResult(setup, Random(seed)));
      }
      expect(seen, participants.toSet());
    });
  });
}
