import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';

import 'ladder_generator.dart';

/// 선택된 참가자의 경로를 실시간으로 따라 그려주는 오버레이.
/// LadderBoard와 같은 좌표계를 쓰기 때문에 Stack으로 겹쳐서 사용한다.
class LadderPathOverlay extends StatefulWidget {
  final LadderStructure structure;
  final int? selectedParticipant;
  final VoidCallback? onArrived;

  const LadderPathOverlay({
    super.key,
    required this.structure,
    required this.selectedParticipant,
    this.onArrived,
  });

  @override
  State<LadderPathOverlay> createState() => _LadderPathOverlayState();
}

class _LadderPathOverlayState extends State<LadderPathOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kPathTraceDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onArrived?.call();
      }
    });
    if (widget.selectedParticipant != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant LadderPathOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedParticipant != oldWidget.selectedParticipant &&
        widget.selectedParticipant != null) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.selectedParticipant;
    if (participant == null) {
      return const SizedBox.expand();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: _LadderPathPainter(
        structure: widget.structure,
        path: widget.structure.pathFor(participant),
        animation: _controller,
      ),
    );
  }
}

class _LadderPathPainter extends CustomPainter {
  final LadderStructure structure;
  final List<LadderPathPoint> path;
  final Animation<double> animation;

  _LadderPathPainter({
    required this.structure,
    required this.path,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final columnGap = size.width / structure.participantCount;
    final rowGap = size.height / structure.rowCount;

    Offset toOffset(LadderPathPoint point) =>
        Offset(columnGap * (point.column + 0.5), rowGap * point.row);

    final offsets = [for (final point in path) toOffset(point)];
    final distances = <double>[
      for (var i = 1; i < offsets.length; i++)
        (offsets[i] - offsets[i - 1]).distance,
    ];
    final totalDistance = distances.fold<double>(0, (sum, d) => sum + d);
    if (totalDistance == 0) return;

    final t = animation.value;
    final pathPaint = Paint()
      ..color = kColorPrimary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var cumulative = 0.0;
    var head = offsets.first;
    final drawnPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (var i = 0; i < distances.length; i++) {
      final segStart = cumulative / totalDistance;
      cumulative += distances[i];
      final segEnd = cumulative / totalDistance;

      if (t <= segStart) break;

      // 이 구간 안에서의 진행도에 살짝 튕기는 커브를 적용한다.
      // 방향이 꺾이는 지점(구간의 끝)에 도착할 때 목표를 살짝 지나쳤다가
      // 되돌아오는 것처럼 보여서 "튕기는" 느낌을 준다.
      final localT = ((t - segStart) / (segEnd - segStart)).clamp(0.0, 1.0);
      final eased = kBounceCurve.transform(localT);
      final current = Offset.lerp(offsets[i], offsets[i + 1], eased)!;

      drawnPath.lineTo(current.dx, current.dy);
      head = current;

      if (t < segEnd) break;
    }

    canvas.drawPath(drawnPath, pathPaint);
    canvas.drawCircle(head, 8, Paint()..color = kColorPrimary);
  }

  @override
  bool shouldRepaint(covariant _LadderPathPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.animation != animation;
  }
}
