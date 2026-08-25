import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

import 'ladder_board.dart';
import 'ladder_generator.dart';
import 'ladder_outcome.dart';
import 'ladder_path_overlay.dart';
import 'ladder_result_card.dart';

/// 참가자 목록과 결과 목록을 받아 사다리를 생성하고, 참가자를 선택하면
/// 경로를 따라가다가 도착 지점에서 결과 카드를 보여주는 화면.
class LadderResultScreen extends StatefulWidget {
  final List<String> participants;
  final List<LadderOutcome> outcomes;

  const LadderResultScreen({
    super.key,
    required this.participants,
    required this.outcomes,
  });

  @override
  State<LadderResultScreen> createState() => _LadderResultScreenState();
}

class _LadderResultScreenState extends State<LadderResultScreen> {
  late final LadderStructure _structure;
  // 위쪽 이름의 표시 순서. 사다리 구조(rungs)는 그대로 두고 이 목록만 섞기 때문에,
  // 재섞기를 하면 참가자가 다른 세로선(column) 자리에 서게 되어 결과가 바뀔 수 있다.
  // (사다리 그림 자체는 항상 같은 물리적 위치에 그려지므로, 표시 순서 = 실제 열 번호)
  late List<String> _participantOrder;
  int? _selectedParticipant;
  int? _revealedColumn;

  @override
  void initState() {
    super.initState();
    // 화면이 다시 그려져도(setState 등) 사다리가 매번 바뀌지 않도록 initState에서 한 번만 생성한다.
    _structure = LadderGenerator.generate(
      participantCount: widget.participants.length,
    );
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
      _revealedColumn = _structure.resultMapping[selected];
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            _LadderLabelRow(
              labels: _participantOrder,
              selectedIndex: _selectedParticipant,
              onSelect: _selectParticipant,
            ),
            const SizedBox(height: kSpacingSm),
            Expanded(
              child: Stack(
                children: [
                  LadderBoard(structure: _structure),
                  LadderPathOverlay(
                    structure: _structure,
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
                                    ? LadderResultCard(
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
            _LadderLabelRow(
              labels: [for (final outcome in widget.outcomes) outcome.label],
            ),
          ],
        ),
      ),
    );
  }
}

class _LadderLabelRow extends StatelessWidget {
  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  const _LadderLabelRow({
    required this.labels,
    this.selectedIndex,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              child: Text(
                labels[i],
                style: i == selectedIndex
                    ? kTextBody1.copyWith(
                        color: kColorPrimary,
                        fontWeight: FontWeight.w700,
                      )
                    : kTextBody1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
