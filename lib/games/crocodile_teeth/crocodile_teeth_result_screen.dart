import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/home_button.dart';

import '../common/turn_trigger_board.dart';
import '../common/turn_trigger_controller.dart';
import 'crocodile_teeth_constants.dart';

const double _kMouthWidth = 300;
const double _kJawGapHeight = 44;
const Color _kJawColor = Color(0xFF3D9B4F);
const Color _kJawBorderColor = Color(0xFF2C7A3A);
const Color _kGumColor = Color(0xFFB6E4B0);

/// 트리거 자리(triggerIndex)는 이미 정해져 있고, 참가자들이 순서대로 이빨을
/// 하나씩 눌러보다가 트리거를 누르면 악어 입이 다무는 결과 화면. 턴 진행/
/// 트리거 판정은 통아저씨와 똑같이 공용 TurnTriggerController가 맡고, 이
/// 화면은 입·이빨 비주얼만 새로 얹는다. 통아저씨의 "튀어오르는" 연출과 달리
/// 입을 다무는 정도는 implicit 애니메이션(AnimatedSlide/AnimatedContainer)
/// 만으로 충분해서 별도 AnimationController 없이 훨씬 짧게 끝난다.
class CrocodileTeethResultScreen extends StatefulWidget {
  final List<String> participants;
  final int triggerIndex;

  const CrocodileTeethResultScreen({
    super.key,
    required this.participants,
    required this.triggerIndex,
  });

  @override
  State<CrocodileTeethResultScreen> createState() =>
      _CrocodileTeethResultScreenState();
}

class _CrocodileTeethResultScreenState
    extends State<CrocodileTeethResultScreen> {
  late final TurnTriggerController _controller = TurnTriggerController(
    participants: widget.participants,
    triggerIndex: widget.triggerIndex,
  );

  void _handleSlotPressed(int index) {
    final isTrigger = _controller.press(index);
    setState(() {});
    if (isTrigger) {
      // 웹/데스크톱에서는 조용히 무시된다 (RouletteWheel의 haptic 처리와 동일한 방식).
      HapticFeedback.heavyImpact().catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('악어 이빨 누르기'),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 트리거가 발동하면 윗턱이 살짝 더 내려갔다 튕기듯
                    // 자리잡으며(kBounceCurve) 아랫턱과 맞물린다.
                    AnimatedSlide(
                      offset: _controller.triggered
                          ? const Offset(0, 0.25)
                          : Offset.zero,
                      duration: kSlowDuration,
                      curve: kBounceCurve,
                      child: _buildTopJaw(),
                    ),
                    // 벌어져 있던 틈(입)이 실제로 좁아지며 닫히는 부분은
                    // 크기 애니메이션이라 overshoot 없는 커브로 안전하게 처리한다.
                    AnimatedContainer(
                      duration: kDefaultDuration,
                      curve: kStandardCurve,
                      height: _controller.triggered ? 4 : _kJawGapHeight,
                    ),
                    _buildBottomJaw(),
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
      return '${_controller.currentParticipant}님이 악어 입을 물게 했어요!';
    }
    return '${_controller.currentParticipant}님 차례예요 — 이빨을 하나 골라보세요';
  }

  Widget _buildTopJaw() {
    return Container(
      width: _kMouthWidth,
      height: 32,
      decoration: BoxDecoration(
        color: _kJawColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(kRadiusXl),
        ),
        border: Border.all(color: _kJawBorderColor, width: 3),
      ),
    );
  }

  Widget _buildBottomJaw() {
    return Container(
      width: _kMouthWidth,
      padding: const EdgeInsets.symmetric(
        vertical: kSpacingSm,
        horizontal: kSpacingMd,
      ),
      decoration: BoxDecoration(
        color: _kGumColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(kRadiusXl),
        ),
        border: Border.all(color: _kJawBorderColor, width: 3),
      ),
      child: TurnTriggerBoard(
        slotCount: kCrocodileTeethSlotCount,
        triggerIndex: widget.triggerIndex,
        pressedIndices: _controller.pressedIndices,
        enabled: !_controller.triggered,
        onSlotPressed: _handleSlotPressed,
        slotBuilder: _buildToothSlot,
        slotSize: 40,
      ),
    );
  }

  Widget _buildToothSlot(
    BuildContext context,
    int index,
    TurnTriggerSlotState state,
  ) {
    final color = switch (state) {
      TurnTriggerSlotState.idle => Colors.white,
      TurnTriggerSlotState.safe => kColorTextDisabled,
      TurnTriggerSlotState.triggered => kColorError,
    };
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 24,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kRadiusSm),
          ),
          border: Border.all(color: kColorBorder),
        ),
      ),
    );
  }
}
