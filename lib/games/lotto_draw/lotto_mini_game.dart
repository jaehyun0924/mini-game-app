import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/models/session_result.dart';

import '../common/winner_count_setup_screen.dart';
import '../mini_game.dart';
import 'lotto_constants.dart';
import 'lotto_result_screen.dart';

/// 로또뽑기를 MiniGame 인터페이스로 감싼 구현체. 참가자 전원을 공 뽑기
/// 기계에 넣어두고, 그 중 당첨 인원 수(setup.pickCount)만큼을 무작위 순서로
/// 뽑아 당첨자로 정한다(computeResult). 화면에서는 진행자가 "다음 공 뽑기"
/// 버튼을 눌러 그 순서대로 하나씩 공개한다 — 제비뽑기와 달리 참가자 개개인이
/// 직접 탭하는 게 아니라 진행자가 순서대로 뽑는 방식이라, 슬롯별 결과 라벨
/// (outcomes) 대신 "몇 명을 뽑을지"라는 개수(pickCount)만 있으면 된다.
class LottoDrawMiniGame extends MiniGame<List<String>> {
  @override
  String get id => 'lotto_draw';

  @override
  String get name => '로또뽑기';

  @override
  int get minParticipants => kLottoMinParticipants;

  @override
  int get maxParticipants => kLottoMaxParticipants;

  @override
  Widget buildAfterParticipants(
    BuildContext context,
    List<String> participants, {
    GameResultCallback? onResult,
  }) {
    return WinnerCountSetupScreen(
      game: this,
      participants: participants,
      question: '참가자 ${participants.length}명 중 몇 명을 뽑을까요?',
      submitLabel: '공 뽑기 시작',
      onResult: onResult,
      buildSetup: (participants, winnerCount) =>
          GameSetup(participants: participants, pickCount: winnerCount),
    );
  }

  @override
  List<String> computeResult(GameSetup setup, Random random) {
    // pickCount는 LottoDrawSetupScreen이 항상 채워서 넘겨준다.
    final winnerCount = setup.pickCount!;
    final shuffled = List<String>.of(setup.participants)..shuffle(random);
    return shuffled.sublist(0, winnerCount);
  }

  @override
  Widget buildPlayScreen(
    BuildContext context,
    GameSetup setup,
    List<String> result, {
    GameResultCallback? onResult,
  }) {
    return LottoDrawResultScreen(
      winners: result,
      totalParticipants: setup.participants.length,
      participants: setup.participants,
      onResult: onResult,
    );
  }
}
