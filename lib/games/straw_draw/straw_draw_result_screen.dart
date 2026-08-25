import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/home_button.dart';

import '../common/shuffle_reveal_board.dart';

/// 참가자 목록과, 이미 각 막대(화면상 물리적 위치)에 무작위로 배정된 결과
/// (outcomes)를 받는 화면. 어떤 막대가 당첨인지는 이미 정해져 있고
/// (StrawDrawMiniGame.computeResult), 이 화면은 참가자들이 순서대로 막대를
/// 하나씩 골라 뽑는 흐름과 애니메이션만 담당한다.
class StrawDrawResultScreen extends StatefulWidget {
  final List<String> participants;
  final List<GameOutcome> outcomes;

  const StrawDrawResultScreen({
    super.key,
    required this.participants,
    required this.outcomes,
  });

  @override
  State<StrawDrawResultScreen> createState() => _StrawDrawResultScreenState();
}

class _StrawDrawResultScreenState extends State<StrawDrawResultScreen> {
  final Set<int> _revealed = {};
  final Map<int, String> _drawnBy = {};
  int _turn = 0;
  bool _boardReady = false;

  bool get _isDone => _turn >= widget.participants.length;

  void _handleTap(int index) {
    setState(() {
      _revealed.add(index);
      _drawnBy[index] = widget.participants[_turn];
      _turn++;

      // 당첨이 나오면 그걸로 게임이 끝난 셈이니, 남은 막대는 누가 뽑을 것도 없이
      // 바로 다 펼쳐서 보여준다 (당첨자 외에는 어차피 결과가 똑같이 "통과"라
      // 한 명씩 더 뽑아볼 이유가 없다).
      if (widget.outcomes[index].isSpecial) {
        for (var i = 0; i < widget.outcomes.length; i++) {
          _revealed.add(i);
        }
        _turn = widget.participants.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제비뽑기 결과'),
        actions: const [HomeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            Text(_statusText, style: kTextTitle),
            const SizedBox(height: kSpacingLg),
            Expanded(
              child: ShuffleRevealBoard(
                itemCount: widget.outcomes.length,
                revealedIndices: _revealed,
                onTap: _isDone ? null : _handleTap,
                onShuffleComplete: () => setState(() => _boardReady = true),
                frontBuilder: _buildFront,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    if (!_boardReady) return '섞는 중...';
    if (_isDone) return '모두 뽑았어요!';
    return '${widget.participants[_turn]}님 차례예요';
  }

  Widget _buildFront(BuildContext context, int index) {
    final outcome = widget.outcomes[index];
    return Container(
      decoration: BoxDecoration(
        color: outcome.isSpecial ? kColorPrimary : kColorSurface,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: outcome.isSpecial ? null : Border.all(color: kColorBorder),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            outcome.label,
            style: kTextBody1.copyWith(
              color: outcome.isSpecial ? Colors.white : kColorTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_drawnBy[index] != null) ...[
            const SizedBox(height: kSpacingXs),
            Text(
              _drawnBy[index]!,
              style: kTextCaption.copyWith(
                color: outcome.isSpecial ? Colors.white70 : kColorTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
