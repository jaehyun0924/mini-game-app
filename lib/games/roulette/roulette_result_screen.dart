import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/widgets/game_result_card.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

import 'roulette_wheel.dart';

/// 참가자 목록과 이미 계산된 당첨자 인덱스(winningIndex)를 받아, "룰렛 돌리기"
/// 버튼을 누르면 룰렛이 돌아가다가 당첨자 섹터에서 멈추고 결과 카드를
/// 보여주는 화면. 당첨자는 이미 정해져 있고(computeResult), 이 화면은
/// 그 결과를 시각적으로 보여주기만 한다.
class RouletteResultScreen extends StatefulWidget {
  final List<String> participants;
  final int winningIndex;

  const RouletteResultScreen({
    super.key,
    required this.participants,
    required this.winningIndex,
  });

  @override
  State<RouletteResultScreen> createState() => _RouletteResultScreenState();
}

class _RouletteResultScreenState extends State<RouletteResultScreen> {
  bool _hasSpun = false;
  bool _settled = false;

  void _spin() {
    setState(() => _hasSpun = true);
  }

  void _handleSettled() {
    setState(() => _settled = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('룰렛 결과')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            const Icon(Icons.arrow_drop_down, color: kColorPrimary, size: 36),
            Expanded(
              child: RouletteWheel(
                labels: widget.participants,
                targetSectorIndex: _hasSpun ? widget.winningIndex : null,
                onSettled: _handleSettled,
              ),
            ),
            const SizedBox(height: kSpacingMd),
            SizedBox(
              height: 96,
              child: Center(
                child: _settled
                    ? GameResultCard(
                        outcome: GameOutcome(
                          label: widget.participants[widget.winningIndex],
                          isSpecial: true,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: kSpacingMd),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _hasSpun ? null : _spin,
                child: const Text('룰렛 돌리기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
