import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';

import 'ladder_generator.dart';

/// LadderStructure를 세로선 -> 가로선 순서로 순차적으로 그려주는 위젯.
/// 화면에 나타나면 자동으로 애니메이션이 재생된다.
class LadderBoard extends StatefulWidget {
  final LadderStructure structure;

  const LadderBoard({super.key, required this.structure});

  @override
  State<LadderBoard> createState() => _LadderBoardState();
}

class _LadderBoardState extends State<LadderBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kRevealDuration)
      ..forward();
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
      painter: _LadderPainter(widget.structure, _controller),
    );
  }
}

class _LadderPainter extends CustomPainter {
  // 전체 타임라인(0.0~1.0) 중 세로선이 다 그려지는 지점.
  // 이후 구간(0.4~1.0)에서 가로선이 순서대로 그려진다.
  static const double _verticalsPhaseEnd = 0.4;

  final LadderStructure structure;
  final Animation<double> animation;

  _LadderPainter(this.structure, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final columnCount = structure.participantCount;
    final columnGap = size.width / columnCount;
    final rowGap = size.height / structure.rowCount;
    final t = animation.value;

    double columnX(int column) => columnGap * (column + 0.5);
    double rowY(int row) => rowGap * (row + 0.5);

    final linePaint = Paint()
      ..color = kColorTextPrimary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 세로선: 왼쪽 열부터 순서대로, 위에서 아래로 자라나며 그려진다.
    for (var column = 0; column < columnCount; column++) {
      final progress = _intervalProgress(
        index: column,
        count: columnCount,
        phaseStart: 0,
        phaseEnd: _verticalsPhaseEnd,
        t: t,
      );
      if (progress <= 0) continue;
      final x = columnX(column);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * progress),
        linePaint,
      );
    }

    // 가로선(다리): 생성 순서(위->아래, 왼쪽->오른쪽)대로, 왼쪽에서 오른쪽으로 자라나며 그려진다.
    final rungCount = structure.rungs.length;
    for (var i = 0; i < rungCount; i++) {
      final progress = _intervalProgress(
        index: i,
        count: rungCount,
        phaseStart: _verticalsPhaseEnd,
        phaseEnd: 1,
        t: t,
      );
      if (progress <= 0) continue;
      final rung = structure.rungs[i];
      final y = rowY(rung.row);
      final x1 = columnX(rung.column);
      final x2 = columnX(rung.column + 1);
      canvas.drawLine(
        Offset(x1, y),
        Offset(x1 + (x2 - x1) * progress, y),
        linePaint,
      );
    }
  }

  /// count개의 요소가 [phaseStart, phaseEnd] 구간을 균등하게 나눠 쓰도록
  /// index번째 요소만의 0~1 진행도를 계산한다.
  double _intervalProgress({
    required int index,
    required int count,
    required double phaseStart,
    required double phaseEnd,
    required double t,
  }) {
    if (count == 0) return 0;
    final span = phaseEnd - phaseStart;
    final begin = (phaseStart + (index / count) * span).clamp(0.0, 1.0);
    final end = (phaseStart + ((index + 1) / count) * span).clamp(0.0, 1.0);
    return Interval(begin, end, curve: kStandardCurve).transform(t);
  }

  @override
  bool shouldRepaint(covariant _LadderPainter oldDelegate) {
    return oldDelegate.structure != structure ||
        oldDelegate.animation != animation;
  }
}
