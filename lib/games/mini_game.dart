import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';

import 'common/outcome_setup_screen.dart';

/// 새 게임을 추가할 때 구현해야 하는 인터페이스.
///
/// "참가자 입력 화면" 다음 단계는 [buildAfterParticipants]로 열어뒀다.
/// 기본 구현은 공용 결과 라벨 입력 화면(OutcomeSetupScreen)으로 넘어가는
/// 것 — 사다리타기처럼 참가자 수만큼 결과를 배정하는 게임에 맞는 흐름이다.
/// 룰렛처럼 결과 라벨을 따로 입력받을 필요 없이 참가자 중 1명만 뽑으면
/// 되는 게임은 이 메서드를 오버라이드해서 결과 입력 없이 바로 게임 화면으로
/// 넘어가면 된다 (RouletteMiniGame 참고).
///
/// [TResult]는 computeResult가 계산한 결과를 buildPlayScreen이 타입 안전하게
/// 받기 위한 게임별 결과 타입이다 (예: 사다리타기는 LadderStructure).
abstract class MiniGame<TResult> {
  /// 게임을 식별하는 키. 표시용 이름(name)과 분리해두면, 나중에 이름을
  /// 바꾸거나 다국어를 붙여도 저장된 결과 기록이 깨지지 않는다.
  String get id;

  /// 홈 화면 등에 보여줄 이름.
  String get name;

  int get minParticipants;
  int get maxParticipants;

  /// 순수 함수: 참가자/설정을 받아 랜덤 결과를 계산한다. 화면을 그리지
  /// 않으므로 애니메이션 없이도, 나중에 결과를 기록만 할 때도 재사용 가능.
  TResult computeResult(GameSetup setup, Random random);

  /// computeResult가 계산한 결과를 받아 애니메이션과 reveal만 담당하는 화면.
  Widget buildPlayScreen(BuildContext context, GameSetup setup, TResult result);

  /// 참가자 입력이 끝난 뒤 이어질 화면. 기본값은 결과 라벨 입력 화면.
  Widget buildAfterParticipants(BuildContext context, List<String> participants) {
    return OutcomeSetupScreen(game: this, participants: participants);
  }

  /// computeResult → buildPlayScreen을 이어서 실행하는 헬퍼. OutcomeSetupScreen과
  /// buildAfterParticipants를 오버라이드하는 게임 양쪽에서 같은 순서로
  /// 호출하기 위해 공용으로 둔다.
  Widget playScreen(BuildContext context, GameSetup setup) {
    final result = computeResult(setup, Random());
    return buildPlayScreen(context, setup, result);
  }
}
