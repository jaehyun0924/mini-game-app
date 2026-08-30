import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';

import '../mini_game.dart';
import 'popup_pirate_constants.dart';
import 'popup_pirate_result_screen.dart';

/// 통아저씨를 MiniGame 인터페이스로 감싼 구현체. 통에 꽂힌 검 중 어느 자리가
/// "트리거"인지만 미리 정해두면 되고(computeResult), 참가자들이 그 자리를
/// 찾아내려고 돌아가며 검을 꽂아보는 진행 자체는 결과 화면(공용
/// TurnTriggerBoard/TurnTriggerController 기반)이 맡는다. 결과 라벨을
/// 입력받을 필요가 없어 buildAfterParticipants를 오버라이드해 바로 게임
/// 화면으로 넘어간다 (RouletteMiniGame과 동일한 패턴).
class PopupPirateMiniGame extends MiniGame<int> {
  @override
  String get id => 'popup_pirate';

  @override
  String get name => '통아저씨';

  @override
  int get minParticipants => kPopupPirateMinParticipants;

  @override
  int get maxParticipants => kPopupPirateMaxParticipants;

  @override
  Widget buildAfterParticipants(
    BuildContext context,
    List<String> participants,
  ) {
    final setup = GameSetup(participants: participants, outcomes: const []);
    return playScreen(context, setup);
  }

  @override
  int computeResult(GameSetup setup, Random random) {
    return random.nextInt(kPopupPirateSlotCount);
  }

  @override
  Widget buildPlayScreen(BuildContext context, GameSetup setup, int result) {
    return PopupPirateResultScreen(
      participants: setup.participants,
      triggerIndex: result,
    );
  }
}
