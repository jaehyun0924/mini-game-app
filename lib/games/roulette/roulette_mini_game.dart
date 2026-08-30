import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';

import '../mini_game.dart';
import 'roulette_constants.dart';
import 'roulette_generator.dart';
import 'roulette_result_screen.dart';

/// 룰렛을 MiniGame 인터페이스로 감싼 구현체. 참가자 이름이 룰렛 섹터에
/// 그대로 들어가고, 한 번 돌려서 걸린 참가자 1명이 결과를 받는 방식이라
/// 결과 라벨 입력 단계(OutcomeSetupScreen)가 필요 없다 —
/// buildAfterParticipants를 오버라이드해서 건너뛴다.
class RouletteMiniGame extends MiniGame<int> {
  @override
  String get id => 'roulette';

  @override
  String get name => '룰렛';

  @override
  int get minParticipants => kRouletteMinParticipants;

  @override
  int get maxParticipants => kRouletteMaxParticipants;

  @override
  Widget buildAfterParticipants(BuildContext context, List<String> participants) {
    return playWithoutOutcomes(context, participants);
  }

  @override
  int computeResult(GameSetup setup, Random random) {
    return RouletteGenerator.generate(
      participantCount: setup.participants.length,
      random: random,
    );
  }

  @override
  Widget buildPlayScreen(BuildContext context, GameSetup setup, int result) {
    return RouletteResultScreen(
      participants: setup.participants,
      winningIndex: result,
    );
  }
}
