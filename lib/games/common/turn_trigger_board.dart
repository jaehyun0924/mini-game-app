import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/spacing.dart';

/// TurnTriggerBoard 슬롯 하나의 현재 상태. slotBuilder가 이 값을 보고
/// idle/safe/triggered 각각 다른 모양을 그린다.
enum TurnTriggerSlotState { idle, safe, triggered }

/// N개 슬롯 중 미리 정해진 1개(triggerIndex)를 찾을 때까지 하나씩 눌러보는
/// 공용 보드. 통아저씨(검)와 악어이빨(이빨)이 이 위에 슬롯 모양(slotBuilder)만
/// 바꿔 끼워서 쓴다.
///
/// "눌렀을 때 저항감 있게 살짝 눌려 들어가는" 마이크로 애니메이션은 슬롯
/// 하나하나를 감싸는 이 위젯이 공통으로 처리하고, 트리거가 눌렸을 때의
/// 과장된 연출(인형이 튀어오르는 등)은 게임마다 완전히 달라서 이 위젯
/// 밖(부모 화면)에서 따로 얹는다 — 이 위젯 자신은 트리거 여부에 따라 행동을
/// 바꾸지 않고, 어떤 슬롯이 눌렸는지만 [onSlotPressed]로 알려준다.
class TurnTriggerBoard extends StatelessWidget {
  final int slotCount;
  final int triggerIndex;
  final Set<int> pressedIndices;
  final bool enabled;
  final ValueChanged<int> onSlotPressed;
  final Widget Function(
    BuildContext context,
    int index,
    TurnTriggerSlotState state,
  )
  slotBuilder;
  final double slotSize;

  const TurnTriggerBoard({
    super.key,
    required this.slotCount,
    required this.triggerIndex,
    required this.pressedIndices,
    required this.enabled,
    required this.onSlotPressed,
    required this.slotBuilder,
    this.slotSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kSpacingSm,
      runSpacing: kSpacingSm,
      alignment: WrapAlignment.center,
      children: [for (var i = 0; i < slotCount; i++) _buildSlot(context, i)],
    );
  }

  Widget _buildSlot(BuildContext context, int index) {
    final pressed = pressedIndices.contains(index);
    final state = !pressed
        ? TurnTriggerSlotState.idle
        : (index == triggerIndex
              ? TurnTriggerSlotState.triggered
              : TurnTriggerSlotState.safe);

    return _TurnTriggerSlot(
      key: ValueKey(index),
      size: slotSize,
      tappable: enabled && !pressed,
      onPressResolved: () => onSlotPressed(index),
      child: slotBuilder(context, index, state),
    );
  }
}

/// 탭하면 저항감 있게 눌려 들어가는 슬롯 하나. 눌리는 동안(kPressDuration)
/// 아래로 살짝 파고드는 모션을 재생한 뒤에야 [onPressResolved]를 호출한다 —
/// 즉시 결과를 알려주지 않고 "밀어 넣는" 시간차를 둬서 조마조마한 느낌을 살린다.
class _TurnTriggerSlot extends StatefulWidget {
  final double size;
  final bool tappable;
  final VoidCallback onPressResolved;
  final Widget child;

  const _TurnTriggerSlot({
    super.key,
    required this.size,
    required this.tappable,
    required this.onPressResolved,
    required this.child,
  });

  @override
  State<_TurnTriggerSlot> createState() => _TurnTriggerSlotState();
}

class _TurnTriggerSlotState extends State<_TurnTriggerSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pushController = AnimationController(
    vsync: this,
    duration: kPressDuration,
  );
  late final Animation<double> _pushIn = CurvedAnimation(
    parent: _pushController,
    curve: kStandardCurve,
  );

  @override
  void dispose() {
    _pushController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _pushController.forward(from: 0).whenComplete(() {
      if (mounted) widget.onPressResolved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tappable ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _pushIn,
        builder: (context, child) {
          final sink = widget.size * 0.16 * _pushIn.value;
          return Transform.translate(offset: Offset(0, sink), child: child);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: widget.child,
        ),
      ),
    );
  }
}
