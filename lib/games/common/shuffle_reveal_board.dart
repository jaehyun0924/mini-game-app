import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';

import 'shuffle_sequence.dart';

const int _kShuffleStepCount = 6;

/// N개 카드를 뒤집힌 상태로 격자에 배치했다가, 무작위로 자리를 몇 번 바꾸며
/// 섞이는 애니메이션을 보여준 뒤, 탭하면 하나씩 뒤집혀서 내용이 드러나는
/// 공용 위젯. 제비뽑기(막대)와 로또뽑기(번호 공)가 이 위젯 위에 각자의
/// 모양(frontBuilder/backBuilder)과 탭 규칙(tappableIndices)만 얹어서 쓴다.
///
/// 카드의 "정체성"(index)은 화면 위치가 섞여도 바뀌지 않는다 — frontBuilder,
/// revealedIndices, onTap의 index는 항상 이 정체성을 가리킨다. 실제로 움직이는
/// 건 화면상 위치뿐이고, 셔플이 끝나면 카드들은 항상 원래(정렬된) 격자 자리로
/// 돌아온다. "무엇이 뒤집혔는지"는 이 위젯이 아니라 부모가 들고 있다
/// (RouletteWheel처럼 controlled 위젯) — 게임마다 다른 진행 규칙(턴제로 아무거나
/// 선택 / 정해진 순서로만 선택)은 부모가 tappableIndices로 표현한다.
class ShuffleRevealBoard extends StatefulWidget {
  final int itemCount;
  final Set<int> revealedIndices;
  final Set<int>? tappableIndices;
  final ValueChanged<int>? onTap;
  final Widget Function(BuildContext context, int index) frontBuilder;
  final Widget Function(BuildContext context, int index)? backBuilder;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onShuffleComplete;

  const ShuffleRevealBoard({
    super.key,
    required this.itemCount,
    required this.revealedIndices,
    this.tappableIndices,
    this.onTap,
    required this.frontBuilder,
    this.backBuilder,
    this.cardWidth = 64,
    this.cardHeight = 88,
    this.onShuffleComplete,
  });

  @override
  State<ShuffleRevealBoard> createState() => _ShuffleRevealBoardState();
}

class _ShuffleRevealBoardState extends State<ShuffleRevealBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shuffleController;
  late final List<List<int>> _arrangements;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _arrangements = ShuffleSequence.generate(
      itemCount: widget.itemCount,
      stepCount: _kShuffleStepCount,
      random: Random(),
    );
    _shuffleController =
        AnimationController(vsync: this, duration: kShuffleDuration)
          ..addStatusListener(_handleStatus)
          ..forward();
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _settled = true);
      widget.onShuffleComplete?.call();
    }
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }

  Offset _slotPosition(int slot, int columns) {
    final col = slot % columns;
    final row = slot ~/ columns;
    return Offset(
      col * (widget.cardWidth + kSpacingSm),
      row * (widget.cardHeight + kSpacingSm),
    );
  }

  Offset _cardOffset(int cardIndex, int columns) {
    final segments = _arrangements.length - 1;
    final tScaled = _shuffleController.value * segments;
    final segIndex = tScaled.floor().clamp(0, segments - 1);
    final localT = kStandardCurve.transform(
      (tScaled - segIndex).clamp(0.0, 1.0),
    );
    final slotA = _arrangements[segIndex][cardIndex];
    final slotB = _arrangements[segIndex + 1][cardIndex];
    return Offset.lerp(
      _slotPosition(slotA, columns),
      _slotPosition(slotB, columns),
      localT,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxColumns = max(
          1,
          (constraints.maxWidth + kSpacingSm) ~/
              (widget.cardWidth + kSpacingSm),
        );
        final columns = min(maxColumns, widget.itemCount);
        final rows = (widget.itemCount / columns).ceil();
        final boardWidth =
            columns * widget.cardWidth + (columns - 1) * kSpacingSm;
        final boardHeight =
            rows * widget.cardHeight + (rows - 1) * kSpacingSm;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: AnimatedBuilder(
              animation: _shuffleController,
              builder: (context, child) {
                return Stack(
                  children: [
                    for (var i = 0; i < widget.itemCount; i++)
                      _buildCard(i, columns),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, int columns) {
    final offset = _cardOffset(index, columns);
    final revealed = widget.revealedIndices.contains(index);
    final tappable =
        !revealed &&
        _settled &&
        (widget.tappableIndices == null ||
            widget.tappableIndices!.contains(index));

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: GestureDetector(
        onTap: tappable ? () => widget.onTap?.call(index) : null,
        child: _FlipCard(
          revealed: revealed,
          front: widget.frontBuilder(context, index),
          back: widget.backBuilder?.call(context, index) ?? _defaultBack(),
        ),
      ),
    );
  }

  Widget _defaultBack() {
    return Container(
      decoration: BoxDecoration(
        color: kColorPrimaryLight,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kColorBorder),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.help_outline, color: kColorPrimary),
    );
  }
}

/// revealed가 false→true로 바뀌면 Y축으로 뒤집히며 back(뒷면 디자인)에서
/// front(공개된 내용)로 전환되는 카드. 뒤집는 중간(90도)에 자연스럽게 내용이
/// 바뀌어 보이도록, 절반은 back을 절반은 front를 좌우 반전해 그린다
/// (반전하지 않으면 뒤집힌 순간 글자가 거울상으로 보인다).
class _FlipCard extends StatefulWidget {
  final bool revealed;
  final Widget front;
  final Widget back;

  const _FlipCard({
    required this.revealed,
    required this.front,
    required this.back,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kDefaultDuration,
      value: widget.revealed ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed && !oldWidget.revealed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = kStandardCurve.transform(_controller.value);
        final angle = t * pi;
        final showBack = t < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? widget.back
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: widget.front,
                ),
        );
      },
    );
  }
}
