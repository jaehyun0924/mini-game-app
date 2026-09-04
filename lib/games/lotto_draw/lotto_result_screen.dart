import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/session_result.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/game_result_card.dart';
import 'package:mini_game_app/widgets/home_button.dart';
import 'package:mini_game_app/widgets/label_row.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

import '../common/game_result_recorder.dart';
import 'ball_jitter_cluster.dart';

/// 이미 뽑혀서 순서가 정해진 당첨자 이름 목록(winners)과 전체 참가자 수를
/// 받는 화면. 당첨자를 실제로 뽑는 계산(무작위 추출)은
/// LottoDrawMiniGame.computeResult에서 이미 끝났고, 이 화면은 "공 뽑기"
/// 버튼을 누를 때마다 그 순서대로 하나씩 공개하는 연출만 담당한다.
/// 뽑힐 때마다 기계 안의 공 개수(remaining)가 하나씩 줄어드는 것으로
/// "그 공이 뽑혀서 빠져나갔다"는 느낌을 준다.
class LottoDrawResultScreen extends StatefulWidget {
  final List<String> winners;
  final int totalParticipants;
  final List<String> participants;
  final GameResultCallback? onResult;

  const LottoDrawResultScreen({
    super.key,
    required this.winners,
    required this.totalParticipants,
    required this.participants,
    this.onResult,
  });

  @override
  State<LottoDrawResultScreen> createState() => _LottoDrawResultScreenState();
}

class _LottoDrawResultScreenState extends State<LottoDrawResultScreen> {
  int _drawnCount = 0;

  bool get _isDone => _drawnCount >= widget.winners.length;

  void _drawNext() {
    if (_isDone) return;
    setState(() => _drawnCount++);

    if (_isDone) {
      final winnerSet = widget.winners.toSet();
      final outcomes = <String, GameOutcome>{
        for (final participant in widget.participants)
          participant: GameOutcome(
            label: winnerSet.contains(participant) ? '당첨' : '통과',
            isSpecial: winnerSet.contains(participant),
          ),
      };
      recordGameResult(context, widget.onResult, SessionResult(outcomes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.totalParticipants - _drawnCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('로또뽑기 결과'),
        actions: const [HomeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            Text(
              _isDone ? '당첨자 발표가 끝났어요!' : '공 뽑기를 눌러 당첨자를 확인하세요',
              style: kTextTitle,
            ),
            const SizedBox(height: kSpacingLg),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BallJitterCluster(ballCount: remaining),
                    if (_drawnCount > 0)
                      GameResultCard(
                        key: ValueKey(_drawnCount),
                        outcome: GameOutcome(
                          label: widget.winners[_drawnCount - 1],
                          isSpecial: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: kSpacingLg),
            SizedBox(
              height: 32,
              child: _drawnCount == 0
                  ? null
                  : LabelRow(labels: widget.winners.sublist(0, _drawnCount)),
            ),
            const SizedBox(height: kSpacingMd),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _isDone ? null : _drawNext,
                child: Text(_isDone ? '완료' : '다음 공 뽑기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
