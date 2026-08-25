import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/motion.dart';

/// 눌렀을 때 살짝 작아졌다가(scale down) 떼면 원래 크기로 돌아오는 공용 버튼 래퍼.
/// 앱 안의 모든 탭 가능한 요소(텍스트 버튼, 아이콘, 카드 등)를 이걸로 감싸서
/// 게임마다 눌림 느낌이 달라지지 않게 한다.
class ShrinkButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const ShrinkButton({super.key, required this.onPressed, required this.child});

  @override
  State<ShrinkButton> createState() => _ShrinkButtonState();
}

class _ShrinkButtonState extends State<ShrinkButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        // 눌린 상태(0.96)와 원래 크기(1.0) 사이를 kPressDuration 동안 오간다.
        scale: _pressed ? 0.96 : 1.0,
        duration: kPressDuration,
        curve: kStandardCurve,
        child: widget.child,
      ),
    );
  }
}
