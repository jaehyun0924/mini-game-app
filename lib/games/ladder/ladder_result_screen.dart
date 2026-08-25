import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/widgets/game_result_card.dart';
import 'package:mini_game_app/widgets/home_button.dart';
import 'package:mini_game_app/widgets/label_row.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

import 'ladder_board.dart';
import 'ladder_generator.dart';
import 'ladder_path_overlay.dart';

/// 참가자 목록과 결과 목록, 그리고 이미 계산된 사다리 구조(structure)를 받아
/// 참가자를 선택하면 경로를 따라가다가 도착 지점에서 결과 카드를 보여주는 화면.
/// 사다리 구조 자체는 LadderMiniGame.computeResult에서 계산해서 넘겨받는다 —
/// 이 화면은 순수하게 애니메이션과 reveal만 담당한다.
class LadderResultScreen extends StatefulWidget {
  final List<String> participants;
  final List<GameOutcome> outcomes;
  final LadderStructure structure;

  const LadderResultScreen({
    super.key,
    required this.participants,
    required this.outcomes,
    required this.structure,
  });

  @override
  State<LadderResultScreen> createState() => _LadderResultScreenState();
}

class _LadderResultScreenState extends State<LadderResultScreen> {
  // 위쪽 이름의 표시 순서. 사다리 구조(rungs)는 그대로 두고 이 목록만 섞기 때문에,
  // 재섞기를 하면 참가자가 다른 세로선(column) 자리에 서게 되어 결과가 바뀔 수 있다.
  // (사다리 그림 자체는 항상 같은 물리적 위치에 그려지므로, 표시 순서 = 실제 열 번호)
  late List<String> _participantOrder;
  int? _selectedParticipant;
  int? _revealedColumn;

  @override
  void initState() {
    super.initState();
    _participantOrder = List.of(widget.participants);
  }

  void _selectParticipant(int index) {
    setState(() {
      _selectedParticipant = index;
      _revealedColumn = null;
    });
  }

  void _handleArrived() {
    final selected = _selectedParticipant;
    if (selected == null) return;
    setState(() {
      _revealedColumn = widget.structure.resultMapping[selected];
    });
  }

  void _shuffleParticipantOrder() {
    setState(() {
      _participantOrder.shuffle(Random());
      _selectedParticipant = null;
      _revealedColumn = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사다리타기 결과'),
        actions: [
          ShrinkButton(
            onPressed: _shuffleParticipantOrder,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: kSpacingSm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shuffle, color: kColorPrimary),
                  SizedBox(width: kSpacingXs),
                  Text('Random', style: TextStyle(color: kColorPrimary)),
                ],
              ),
            ),
          ),
          const HomeButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            LabelRow(
              labels: _participantOrder,
              selectedIndex: _selectedParticipant,
              onSelect: _selectParticipant,
            ),
            const SizedBox(height: kSpacingSm),
            Expanded(
              child: Stack(
                children: [
                  LadderBoard(structure: widget.structure),
                  LadderPathOverlay(
                    structure: widget.structure,
                    selectedParticipant: _selectedParticipant,
                    onArrived: _handleArrived,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.participants.length; i++)
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: i == _revealedColumn
                                    ? GameResultCard(
                                        outcome: widget.outcomes[i],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpacingSm),
            LabelRow(
              labels: [for (final outcome in widget.outcomes) outcome.label],
            ),
          ],
        ),
      ),
    );
  }
}
