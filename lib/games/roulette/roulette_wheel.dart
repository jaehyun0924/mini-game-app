import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/text_styles.dart';

import 'roulette_angles.dart';

/// labels(참가자 이름)로 등분된 원판을 그리고, targetSectorIndex가 정해지면
/// 그 섹터가 12시 방향(포인터 고정 위치) 아래 멈추도록 여러 바퀴 돌아가는 위젯.
class RouletteWheel extends StatefulWidget {
  final List<String> labels;
  final int? targetSectorIndex;
  final VoidCallback? onSettled;

  const RouletteWheel({
    super.key,
    required this.labels,
    required this.targetSectorIndex,
    this.onSettled,
  });

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with SingleTickerProviderStateMixin {
  // 전체 타임라인(0.0~1.0) 중 회전이 끝나는 지점. 이후 구간(0.9~1.0)에서
  // 당첨 섹터만 살짝 커지는 하이라이트가 재생된다.
  static const double _spinPhaseEnd = 0.9;

  late final AnimationController _controller;
  // 스핀이 끝날 때마다 갱신되는 누적 회전각. 다음 스핀은 여기서부터 이어서 돈다.
  double _currentRotation = 0;
  double _spinBeginRotation = 0;
  double _spinEndRotation = 0;
  int _lastCrossedBoundary = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kSpinDuration)
      ..addListener(_handleTick)
      ..addStatusListener(_handleStatus);
  }

  @override
  void didUpdateWidget(covariant RouletteWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.targetSectorIndex;
    if (target != null && target != oldWidget.targetSectorIndex) {
      _startSpin(target);
    }
  }

  void _startSpin(int winningIndex) {
    _spinBeginRotation = _currentRotation;
    _spinEndRotation = RouletteAngles.computeTargetRotation(
      currentRotation: _currentRotation,
      winningIndex: winningIndex,
      sectorCount: widget.labels.length,
    );
    _lastCrossedBoundary = _boundaryIndex(_spinBeginRotation);
    _controller
      ..reset()
      ..forward();
  }

  double get _currentAngle {
    final spinT = Interval(
      0,
      _spinPhaseEnd,
      curve: kSpinCurve,
    ).transform(_controller.value);
    return ui.lerpDouble(_spinBeginRotation, _spinEndRotation, spinT)!;
  }

  int _boundaryIndex(double rotation) =>
      (rotation / RouletteAngles.sectorAngle(widget.labels.length)).floor();

  void _handleTick() {
    final boundary = _boundaryIndex(_currentAngle);
    if (boundary != _lastCrossedBoundary) {
      _lastCrossedBoundary = boundary;
      // 웹/데스크톱에서는 조용히 무시된다. 혹시 모를 예외가 스핀 애니메이션을
      // 멈추지 않도록 방어한다.
      HapticFeedback.lightImpact().catchError((_) {});
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _currentRotation = _spinEndRotation % (2 * pi);
      widget.onSettled?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _RouletteWheelPainter(
        labels: widget.labels,
        winningIndex: widget.targetSectorIndex,
        spinBeginRotation: _spinBeginRotation,
        spinEndRotation: _spinEndRotation,
        spinPhaseEnd: _spinPhaseEnd,
        controller: _controller,
      ),
    );
  }
}

class _RouletteWheelPainter extends CustomPainter {
  final List<String> labels;
  final int? winningIndex;
  final double spinBeginRotation;
  final double spinEndRotation;
  final double spinPhaseEnd;
  final Animation<double> controller;

  _RouletteWheelPainter({
    required this.labels,
    required this.winningIndex,
    required this.spinBeginRotation,
    required this.spinEndRotation,
    required this.spinPhaseEnd,
    required this.controller,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final sectorCount = labels.length;
    final sectorAngle = RouletteAngles.sectorAngle(sectorCount);

    final spinT = Interval(
      0,
      spinPhaseEnd,
      curve: kSpinCurve,
    ).transform(controller.value);
    final rotation = ui.lerpDouble(spinBeginRotation, spinEndRotation, spinT)!;
    final highlightT = Interval(
      spinPhaseEnd,
      1,
      curve: kBounceCurve,
    ).transform(controller.value);

    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (var i = 0; i < sectorCount; i++) {
      final isWinning = i == winningIndex && highlightT > 0;
      final sectorRadius = isWinning ? radius * (1 + 0.06 * highlightT) : radius;
      // drawArc는 0=3시 기준이라, 12시 기준으로 세운 회전각 계산과 맞추려면
      // -pi/2 오프셋이 반드시 필요하다.
      final startAngle = -pi / 2 + i * sectorAngle;
      final rect = Rect.fromCircle(center: Offset.zero, radius: sectorRadius);

      final fillPaint = Paint()
        ..color = isWinning
            ? kColorPrimary
            : (i.isEven ? kColorSurface : kColorPrimaryLight);
      canvas.drawArc(rect, startAngle, sectorAngle, true, fillPaint);

      final borderPaint = Paint()
        ..color = kColorBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(rect, startAngle, sectorAngle, true, borderPaint);

      // 라벨: 섹터 중심 방향으로 캔버스를 회전시켜서, 바퀴살처럼 중심에서
      // 바깥으로 뻗는 방향으로 눕혀 놓는다.
      final labelAngle = startAngle + sectorAngle / 2;
      canvas.save();
      canvas.rotate(labelAngle);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: kTextBody2.copyWith(
            color: isWinning ? Colors.white : kColorTextPrimary,
            fontWeight: isWinning ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        ellipsis: '…',
        maxLines: 1,
      )..layout(maxWidth: sectorRadius * 0.7);
      textPainter.paint(
        canvas,
        Offset(sectorRadius * 0.55 - textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RouletteWheelPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.winningIndex != winningIndex ||
        oldDelegate.spinBeginRotation != spinBeginRotation ||
        oldDelegate.spinEndRotation != spinEndRotation ||
        oldDelegate.controller != controller;
  }
}
