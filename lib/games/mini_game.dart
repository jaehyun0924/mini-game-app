import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/models/session_result.dart';

import 'common/outcome_setup_screen.dart';

/// 새 게임을 추가할 때 구현해야 하는 인터페이스.
///
/// "참가자 입력 화면" 다음 단계는 [buildAfterParticipants]로 열어뒀다.
/// 기본 구현은 공용 결과 라벨 입력 화면(OutcomeSetupScreen)으로 넘어가는
/// 것 — 사다리타기처럼 참가자 수만큼 결과를 배정하는 게임에 맞는 흐름이다.
/// 룰렛처럼 결과 라벨을 따로 입력받을 필요 없이 참가자 중 1명만 뽑으면
/// 되는 게임은 이 메서드를 오버라이드해서 [playWithoutOutcomes]를 바로
/// 호출하면 된다 (RouletteMiniGame 참고).
///
/// [TResult]는 computeResult가 계산한 결과를 buildPlayScreen이 타입 안전하게
/// 받기 위한 게임별 결과 타입이다 (예: 사다리타기는 LadderStructure).
///
/// [onResult]는 그룹 안에서 게임을 시작했을 때만 채워지는 콜백으로, 참가자
/// 입력 화면(ParticipantSetupScreen)에서 만들어져 buildAfterParticipants →
/// playScreen → buildPlayScreen을 거쳐 실제 결과 화면까지 그대로 전달된다.
/// 어디서 게임이 "끝났다"고 판단할지는 게임마다 달라서(사다리타기는 결과가
/// computeResult 시점에 이미 정해지지만, 통아저씨류는 참가자가 실제로 트리거를
/// 눌러야 결정된다) 최종 호출은 각 결과 화면이 맡는다.
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
  Widget buildPlayScreen(
    BuildContext context,
    GameSetup setup,
    TResult result, {
    GameResultCallback? onResult,
  });

  /// 참가자 입력이 끝난 뒤 이어질 화면. 기본값은 결과 라벨 입력 화면.
  Widget buildAfterParticipants(
    BuildContext context,
    List<String> participants, {
    GameResultCallback? onResult,
  }) {
    return OutcomeSetupScreen(
      game: this,
      participants: participants,
      onResult: onResult,
    );
  }

  /// buildAfterParticipants에서 결과 라벨 입력 없이 곧장 게임 화면으로 넘어가고
  /// 싶을 때 쓰는 헬퍼. 룰렛, 통아저씨, 악어이빨처럼 참가자 중 하나(혹은 트리거
  /// 위치)만 무작위로 뽑으면 끝나는 게임이 buildAfterParticipants를 오버라이드해서
  /// 이 메서드 하나만 호출하면 된다.
  Widget playWithoutOutcomes(
    BuildContext context,
    List<String> participants, {
    GameResultCallback? onResult,
  }) {
    return playScreen(
      context,
      GameSetup(participants: participants),
      onResult: onResult,
    );
  }

  /// computeResult → buildPlayScreen을 이어서 실행하는 헬퍼. OutcomeSetupScreen과
  /// buildAfterParticipants를 오버라이드하는 게임 양쪽에서 같은 순서로
  /// 호출하기 위해 공용으로 둔다.
  Widget playScreen(
    BuildContext context,
    GameSetup setup, {
    GameResultCallback? onResult,
  }) {
    final result = computeResult(setup, Random());
    return buildPlayScreen(context, setup, result, onResult: onResult);
  }
}
