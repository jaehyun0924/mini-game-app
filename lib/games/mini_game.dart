import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';

/// 새 게임을 추가할 때 구현해야 하는 인터페이스.
///
/// "참가자 설정 화면"은 여기 멤버로 두지 않았다 — 지금 있는 모든 게임이
/// "참가자 입력 → 결과 라벨 입력"이라는 동일한 흐름을 쓰기 때문에
/// lib/games/common/의 공용 화면 2개로 대신한다. 나중에 이 흐름과
/// 다른 참가자 설정이 필요한 게임(예: 결과 라벨 없이 순서만 정하는 게임)이
/// 생기면, 그때 이 인터페이스에 참가자 설정 화면을 만드는 메서드를 추가하고
/// 공용 화면은 기본 구현으로 남기면 된다.
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
}
