import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';

import 'shrink_button.dart';

/// 앱 전역에서 쓰는 파란색 채움 버튼(주요 액션용). ElevatedButton 대신 이걸 쓴다.
/// ShrinkButton으로 감싸져 있어서 눌리는 느낌이 다른 버튼들과 동일하다.
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const PrimaryButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return ShrinkButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? kColorPrimary : kColorTextDisabled,
          borderRadius: BorderRadius.circular(kRadiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingLg,
            vertical: 14,
          ),
          // widthFactor/heightFactor를 1로 주면, 너비가 강제되지 않는 한(Center 안 등)
          // 내용물 크기만큼만 차지하고, SizedBox(width: double.infinity)처럼 너비가
          // 강제될 때만 그 너비를 채우면서 내용을 가운데 정렬한다.
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1,
            heightFactor: 1,
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
