import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/models/session_result.dart';

import '../common/winner_count_setup_screen.dart';
import '../mini_game.dart';
import 'straw_draw_constants.dart';
import 'straw_draw_result_screen.dart';

/// 제비뽑기를 MiniGame 인터페이스로 감싼 구현체. 참가자 수만큼 막대를 놓고
/// 그 중 당첨 인원 수만큼 "당첨" 결과를 참가자 순서와 무관하게 무작위
/// 배정한 뒤(computeResult), 화면에서는 참가자들이 턴제로 아무 막대나
/// 골라 뽑는다 — 어느 막대가 당첨인지는 이미 정해져 있으므로, 누가 어떤
/// 막대를 뽑든 확률은 동일하다.
class StrawDrawMiniGame extends MiniGame<List<GameOutcome>> {
  @override
  String get id => 'straw_draw';

  @override
  String get name => '제비뽑기';

  @override
  int get minParticipants => kStrawDrawMinParticipants;

  @override
  int get maxParticipants => kStrawDrawMaxParticipants;

  @override
  Widget buildAfterParticipants(
    BuildContext context,
    List<String> participants, {
    GameResultCallback? onResult,
  }) {
    return WinnerCountSetupScreen(
      game: this,
      participants: participants,
      question: '참가자 ${participants.length}명 중 몇 명이 당첨될까요?',
      submitLabel: '제비뽑기 시작',
      onResult: onResult,
      buildSetup: (participants, winnerCount) {
        final outcomes = [
          for (var i = 0; i < participants.length; i++)
            GameOutcome(
              label: i < winnerCount ? '당첨' : '통과',
              isSpecial: i < winnerCount,
            ),
        ];
        return GameSetup(participants: participants, outcomes: outcomes);
      },
    );
  }

  @override
  List<GameOutcome> computeResult(GameSetup setup, Random random) {
    return List<GameOutcome>.of(setup.outcomes)..shuffle(random);
  }

  @override
  Widget buildPlayScreen(
    BuildContext context,
    GameSetup setup,
    List<GameOutcome> result, {
    GameResultCallback? onResult,
  }) {
    return StrawDrawResultScreen(
      participants: setup.participants,
      outcomes: result,
      onResult: onResult,
    );
  }
}
