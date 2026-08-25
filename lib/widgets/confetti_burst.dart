import 'dart:math';

import 'package:flutter/material.dart';

/// 카드 주변으로 작은 색종이 조각이 위로 튀었다가 중력에 끌려 떨어지는
/// 짧은 1회성 연출. 화면에 나타나면 자동으로 재생되고 끝나면 스스로 멈춘다.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = [
    Color(0xFF3182F6),
    Color(0xFFF04452),
    Color(0xFFFFC107),
    Color(0xFF4CAF50),
    Color(0xFFAB47BC),
  ];

  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    final random = Random();
    _pieces = List.generate(16, (_) {
      // 위쪽 반원(왼쪽 위 ~ 오른쪽 위) 방향으로 퍼지도록 각도를 제한한다.
      final angle = -pi / 2 + (random.nextDouble() - 0.5) * pi;
      return _ConfettiPiece(
        angle: angle,
        speed: 80 + random.nextDouble() * 60,
        color: _colors[random.nextInt(_colors.length)],
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(120, 120),
        painter: _ConfettiPainter(pieces: _pieces, animation: _controller),
      ),
    );
  }
}

class _ConfettiPiece {
  final double angle;
  final double speed;
  final Color color;
  final double rotationSpeed;

  _ConfettiPiece({
    required this.angle,
    required this.speed,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final Animation<double> animation;

  _ConfettiPainter({required this.pieces, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final opacity = 1 - t;

    for (final piece in pieces) {
      final dx = cos(piece.angle) * piece.speed * t;
      // sin(piece.angle)*speed*t로 초반에 튀어오르고, 중력 항(120*t*t)으로 떨어진다.
      final dy = sin(piece.angle) * piece.speed * t + 120 * t * t;
      final position = center + Offset(dx, dy);

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(piece.rotationSpeed * t * pi);
      canvas.drawRect(
        const Rect.fromLTWH(-3, -5, 6, 10),
        Paint()..color = piece.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
