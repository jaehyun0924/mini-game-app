import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/session_result.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/home_button.dart';

import '../common/game_result_recorder.dart';
import '../common/turn_trigger_board.dart';
import '../common/turn_trigger_controller.dart';
import 'popup_pirate_constants.dart';

const double _kBarrelWidth = 320;
const double _kBarrelHeight = 240;
const Color _kBarrelColor = Color(0xFF9C6B3E);
const Color _kBarrelBorderColor = Color(0xFF6B4423);
const List<Color> _kSwordColors = [
  kColorPrimary,
  Color(0xFF4CAF50),
  Color(0xFFFFC107),
  Color(0xFFAB47BC),
  Color(0xFFFF7043),
];

/// 트리거 자리(triggerIndex)는 이미 정해져 있고, 참가자들이 순서대로 검을
/// 하나씩 골라 통에 꽂아보다가 트리거를 뽑으면 통 아저씨가 튀어오르는 결과
/// 화면. 턴 진행/트리거 판정은 공용 TurnTriggerController가 맡고, 이 화면은
/// 통·검 비주얼과 트리거 시의 과장된 점프 연출만 새로 얹는다.
class PopupPirateResultScreen extends StatefulWidget {
  final List<String> participants;
  final int triggerIndex;
  final GameResultCallback? onResult;

  const PopupPirateResultScreen({
    super.key,
    required this.participants,
    required this.triggerIndex,
    this.onResult,
  });

  @override
  State<PopupPirateResultScreen> createState() =>
      _PopupPirateResultScreenState();
}

class _PopupPirateResultScreenState extends State<PopupPirateResultScreen>
    with SingleTickerProviderStateMixin {
  late final TurnTriggerController _controller = TurnTriggerController(
    participants: widget.participants,
    triggerIndex: widget.triggerIndex,
  );

  // 통 아저씨가 튀어오르는 과장된 연출용 컨트롤러. 트리거가 눌리기 전엔 0에
  // 머물러 있다가, 트리거 순간 딱 한 번만 재생된다.
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: kSlowDuration,
  );

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _handleSlotPressed(int index) {
    final isTrigger = _controller.press(index);
    setState(() {});
    if (isTrigger) {
      // 웹/데스크톱에서는 조용히 무시된다 (RouletteWheel의 haptic 처리와 동일한 방식).
      HapticFeedback.heavyImpact().catchError((_) {});
      _popController.forward();

      final triggeredBy = _controller.currentParticipant;
      final outcomes = <String, GameOutcome>{
        for (final participant in widget.participants)
          participant: GameOutcome(
            label: participant == triggeredBy ? '커피 사기' : '생존',
            isSpecial: participant == triggeredBy,
          ),
      };
      recordGameResult(context, widget.onResult, SessionResult(outcomes));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통아저씨 결과'),
        actions: const [HomeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            Text(_statusText, style: kTextTitle, textAlign: TextAlign.center),
            const SizedBox(height: kSpacingLg),
            Expanded(
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // 통 아저씨는 평소엔 통 뒤에 완전히 가려져 있다가, 튀어오를
                    // 때만 통 위 테두리 밖으로 모습을 드러낸다 — 그래서 통보다
                    // 먼저 그려서(Stack 아래쪽) 통에 가려지게 한다.
                    AnimatedBuilder(
                      animation: _popController,
                      builder: (context, child) {
                        final t = _popController.value;
                        // 0~0.5 구간에서 튀어오르고, 0.5~1 구간에서 좌우로
                        // 통통 튀며 잦아드는 흔들림을 더해 "과장된" 느낌을 낸다.
                        final jump =
                            -180 * Curves.easeOut.transform(min(t * 2, 1));
                        final wobble = t > 0.5
                            ? sin((t - 0.5) * pi * 8) * 8 * (1 - (t - 0.5) * 2)
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(0, jump),
                          child: Transform.rotate(
                            angle: wobble * pi / 180,
                            child: child,
                          ),
                        );
                      },
                      child: _buildPirate(),
                    ),
                    _buildBarrel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    if (_controller.triggered) {
      return '${_controller.currentParticipant}님이 통 아저씨를 튀어오르게 했어요!';
    }
    return '${_controller.currentParticipant}님 차례예요 — 검을 하나 골라보세요';
  }

  Widget _buildBarrel() {
    return Container(
      width: _kBarrelWidth,
      height: _kBarrelHeight,
      padding: const EdgeInsets.all(kSpacingMd),
      decoration: BoxDecoration(
        color: _kBarrelColor,
        borderRadius: BorderRadius.circular(kRadiusXl),
        border: Border.all(color: _kBarrelBorderColor, width: 4),
      ),
      child: Center(
        child: TurnTriggerBoard(
          slotCount: kPopupPirateSlotCount,
          triggerIndex: widget.triggerIndex,
          pressedIndices: _controller.pressedIndices,
          enabled: !_controller.triggered,
          onSlotPressed: _handleSlotPressed,
          slotBuilder: _buildSwordSlot,
          slotSize: 48,
        ),
      ),
    );
  }

  Widget _buildSwordSlot(
    BuildContext context,
    int index,
    TurnTriggerSlotState state,
  ) {
    final handleColor = switch (state) {
      TurnTriggerSlotState.idle => _kSwordColors[index % _kSwordColors.length],
      TurnTriggerSlotState.safe => kColorTextDisabled,
      TurnTriggerSlotState.triggered => kColorError,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 22,
          height: 14,
          decoration: BoxDecoration(
            color: handleColor,
            borderRadius: BorderRadius.circular(kRadiusSm),
          ),
        ),
      ],
    );
  }

  Widget _buildPirate() {
    return SizedBox(
      width: 72,
      height: 88,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 20,
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD8B8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: Container(
              width: 68,
              height: 24,
              decoration: BoxDecoration(
                color: kColorError,
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
            ),
          ),
          Positioned(
            top: 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_eyeDot(), const SizedBox(width: 18), _eyeDot()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eyeDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: kColorTextPrimary,
        shape: BoxShape.circle,
      ),
    );
  }
}
