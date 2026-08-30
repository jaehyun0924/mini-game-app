import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';

import '../mini_game.dart';
import 'crocodile_teeth_constants.dart';
import 'crocodile_teeth_result_screen.dart';

/// 악어 이빨 누르기를 MiniGame 인터페이스로 감싼 구현체. 이빨 중 어느
/// 자리가 "트리거"인지만 미리 정해두면 되고(computeResult), 참가자들이 그
/// 자리를 찾아내려고 돌아가며 이빨을 눌러보는 진행 자체는 통아저씨와 똑같이
/// 공용 TurnTriggerBoard/TurnTriggerController가 맡는다 — 게임별로 새로
/// 만든 건 결과 화면의 비주얼뿐이라 구현이 짧다.
class CrocodileTeethMiniGame extends MiniGame<int> {
  @override
  String get id => 'crocodile_teeth';

  @override
  String get name => '악어 이빨 누르기';

  @override
  int get minParticipants => kCrocodileTeethMinParticipants;

  @override
  int get maxParticipants => kCrocodileTeethMaxParticipants;

  @override
  Widget buildAfterParticipants(
    BuildContext context,
    List<String> participants,
  ) {
    return playWithoutOutcomes(context, participants);
  }

  @override
  int computeResult(GameSetup setup, Random random) {
    return random.nextInt(kCrocodileTeethSlotCount);
  }

  @override
  Widget buildPlayScreen(BuildContext context, GameSetup setup, int result) {
    return CrocodileTeethResultScreen(
      participants: setup.participants,
      triggerIndex: result,
    );
  }
}
