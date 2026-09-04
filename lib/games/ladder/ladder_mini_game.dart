import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/models/session_result.dart';

import '../mini_game.dart';
import 'ladder_constants.dart';
import 'ladder_generator.dart';
import 'ladder_result_screen.dart';

/// 사다리타기를 MiniGame 인터페이스로 감싼 구현체. 다른 게임을 추가할 때
/// 참고할 레퍼런스 구현체 역할을 한다.
class LadderMiniGame extends MiniGame<LadderStructure> {
  @override
  String get id => 'ladder';

  @override
  String get name => '사다리타기';

  @override
  int get minParticipants => kMinParticipants;

  @override
  int get maxParticipants => kMaxParticipants;

  @override
  LadderStructure computeResult(GameSetup setup, Random random) {
    return LadderGenerator.generate(
      participantCount: setup.participants.length,
      random: random,
    );
  }

  @override
  Widget buildPlayScreen(
    BuildContext context,
    GameSetup setup,
    LadderStructure result, {
    GameResultCallback? onResult,
  }) {
    return LadderResultScreen(
      participants: setup.participants,
      outcomes: setup.outcomes,
      structure: result,
      onResult: onResult,
    );
  }
}
