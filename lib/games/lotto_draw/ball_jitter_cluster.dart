import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';

const double _kDrumSize = 220;
const double _kBallSize = 28;
// 공이 원 안쪽 어디까지 흩어질 수 있는지의 반지름. 드럼 테두리에 걸리지
// 않도록 드럼 반지름보다 공 하나 크기만큼 안쪽으로 여유를 둔다.
const double _kScatterRadius = _kDrumSize / 2 - _kBallSize;

/// 로또 기계 안에서 공들이 제자리에서 잘게 흔들리는 모습을 표현하는 위젯.
/// 실제 물리 시뮬레이션 대신, 공마다 서로 다른 위상(phase)의 사인파로
/// 흔드는 정도로 충분하다는 판단(로드맵 문서 참고)에 따라 이렇게 구현했다.
/// ballCount가 바뀌면(공을 하나 뽑으면) 새 배치로 다시 흩뿌린다.
class BallJitterCluster extends StatefulWidget {
  final int ballCount;

  const BallJitterCluster({super.key, required this.ballCount});

  @override
  State<BallJitterCluster> createState() => _BallJitterClusterState();
}

class _BallJitterClusterState extends State<BallJitterCluster>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_BallSeed> _seeds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _seeds = _generateSeeds(widget.ballCount);
  }

  @override
  void didUpdateWidget(covariant BallJitterCluster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ballCount != oldWidget.ballCount) {
      _seeds = _generateSeeds(widget.ballCount);
    }
  }

  List<_BallSeed> _generateSeeds(int count) {
    final random = Random();
    return List.generate(count, (_) {
      // 드럼 안쪽 원 범위에서 무작위 기준 위치를 잡고, 그 위치를 중심으로
      // 사인파를 타며 잘게 떨리게 한다.
      final angle = random.nextDouble() * 2 * pi;
      final radius = sqrt(random.nextDouble()) * _kScatterRadius;
      return _BallSeed(
        base: Offset(cos(angle), sin(angle)) * radius,
        phase: random.nextDouble() * 2 * pi,
        speed: 4 + random.nextDouble() * 3,
        jitter: 4 + random.nextDouble() * 4,
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
    return Container(
      width: _kDrumSize,
      height: _kDrumSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kColorPrimaryLight,
        border: Border.all(color: kColorPrimary, width: 3),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [for (final seed in _seeds) _buildBall(seed)],
          );
        },
      ),
    );
  }

  Widget _buildBall(_BallSeed seed) {
    final t = _controller.value * 2 * pi;
    final dx = seed.base.dx + sin(t * seed.speed + seed.phase) * seed.jitter;
    final dy =
        seed.base.dy + cos(t * seed.speed * 1.3 + seed.phase) * seed.jitter;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: _kBallSize,
        height: _kBallSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: kColorPrimary,
        ),
      ),
    );
  }
}

class _BallSeed {
  final Offset base;
  final double phase;
  final double speed;
  final double jitter;

  _BallSeed({
    required this.base,
    required this.phase,
    required this.speed,
    required this.jitter,
  });
}
