import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/popup_pirate/popup_pirate_constants.dart';
import 'package:mini_game_app/games/popup_pirate/popup_pirate_mini_game.dart';
import 'package:mini_game_app/models/game_setup.dart';

void main() {
  group('PopupPirateMiniGame.computeResult', () {
    test('항상 유효한 슬롯 인덱스를 뽑는다', () {
      final game = PopupPirateMiniGame();
      final setup = GameSetup(participants: ['A', 'B']);

      for (var seed = 0; seed < 50; seed++) {
        final result = game.computeResult(setup, Random(seed));
        expect(result, greaterThanOrEqualTo(0));
        expect(result, lessThan(kPopupPirateSlotCount));
      }
    });

    test('여러 번 뽑으면 모든 슬롯이 트리거로 선택될 수 있다', () {
      final game = PopupPirateMiniGame();
      final setup = GameSetup(participants: ['A', 'B']);

      final seen = <int>{};
      for (var seed = 0; seed < 300; seed++) {
        seen.add(game.computeResult(setup, Random(seed)));
      }
      expect(seen, List.generate(kPopupPirateSlotCount, (i) => i).toSet());
    });
  });
}
