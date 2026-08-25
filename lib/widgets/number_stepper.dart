import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';

import 'shrink_button.dart';

/// -/+ 버튼으로 숫자를 min~max 사이에서 조절하는 공용 스테퍼.
/// 제비뽑기(당첨 인원 수), 로또뽑기(번호 범위·뽑을 개수)처럼 참가자 이름
/// 대신 개수만 정하면 되는 설정 화면에서 반복해서 쓴다.
class NumberStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String label;
  final String suffix;

  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: kTextBody2),
        const SizedBox(height: kSpacingSm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 72,
              child: Text(
                '$value$suffix',
                textAlign: TextAlign.center,
                style: kTextHeading2,
              ),
            ),
            _StepButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return ShrinkButton(
      onPressed: onPressed,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kColorSurface,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: kColorBorder),
        ),
        child: Icon(icon, color: enabled ? kColorPrimary : kColorTextDisabled),
      ),
    );
  }
}
