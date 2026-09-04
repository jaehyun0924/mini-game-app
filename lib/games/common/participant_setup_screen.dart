import 'package:flutter/material.dart';
import 'package:mini_game_app/models/group.dart';
import 'package:mini_game_app/models/session_result.dart';
import 'package:mini_game_app/services/recent_participants_service.dart';
import 'package:mini_game_app/services/session_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

import '../mini_game.dart';

/// 참가자 이름을 입력받는 화면. 게임마다 다른 로직이 없어서 모든 게임이
/// 공용으로 쓴다 (MiniGame.minParticipants/maxParticipants만 게임별로 다름).
///
/// [group]이 채워져 있으면(그룹 안에서 게임을 시작한 경우) 게임이 끝났을 때
/// 그 그룹의 sessions에 결과를 저장하는 콜백을 만들어 게임 화면까지 전달한다.
/// group이 null이면(홈 화면에서 바로 시작한 경우) 저장 없이 그냥 플레이만 한다.
class ParticipantSetupScreen extends StatefulWidget {
  final MiniGame game;
  final GroupModel? group;

  const ParticipantSetupScreen({super.key, required this.game, this.group});

  @override
  State<ParticipantSetupScreen> createState() =>
      _ParticipantSetupScreenState();
}

class _ParticipantSetupScreenState extends State<ParticipantSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final List<String> _participants = [];
  String? _errorText;
  List<String> _recentNames = [];

  @override
  void initState() {
    super.initState();
    _loadRecentNames();
  }

  Future<void> _loadRecentNames() async {
    final names = await RecentParticipantsService().load(widget.group?.id);
    if (!mounted) return;
    setState(() => _recentNames = names);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = '이름을 입력해주세요');
      _nameFocusNode.requestFocus();
      return;
    }
    if (_participants.length >= widget.game.maxParticipants) {
      setState(
        () => _errorText = '최대 ${widget.game.maxParticipants}명까지 추가할 수 있어요',
      );
      _nameFocusNode.requestFocus();
      return;
    }
    if (_participants.contains(name)) {
      setState(() => _errorText = '이미 추가된 이름이에요');
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() {
      _participants.add(name);
      _nameController.clear();
      _errorText = null;
    });
    _nameFocusNode.requestFocus();
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
      _errorText = null;
    });
  }

  void _showRecentParticipantsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final available = _recentNames
                .where((name) => !_participants.contains(name))
                .toList();
            final canAddMore =
                _participants.length < widget.game.maxParticipants;
            return Padding(
              padding: const EdgeInsets.all(kSpacingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('최근 참가자', style: kTextTitle),
                      ),
                      if (available.isNotEmpty)
                        TextButton(
                          onPressed: canAddMore
                              ? () {
                                  final remaining =
                                      widget.game.maxParticipants -
                                      _participants.length;
                                  setState(() {
                                    _participants.addAll(
                                      available.take(remaining),
                                    );
                                  });
                                  Navigator.pop(sheetContext);
                                }
                              : null,
                          child: const Text('전체 추가'),
                        ),
                    ],
                  ),
                  const SizedBox(height: kSpacingSm),
                  if (available.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: kSpacingMd,
                      ),
                      child: Text(
                        canAddMore ? '더 불러올 수 있는 이름이 없어요' : '이미 최대 인원이에요',
                        style: kTextBody2,
                      ),
                    )
                  else
                    Wrap(
                      spacing: kSpacingSm,
                      runSpacing: kSpacingSm,
                      children: [
                        for (final name in available)
                          ActionChip(
                            label: Text(name),
                            onPressed: canAddMore
                                ? () {
                                    setState(() => _participants.add(name));
                                    setSheetState(() {});
                                  }
                                : null,
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  GameResultCallback? _buildOnResult() {
    final group = widget.group;
    if (group == null) return null;
    final participants = List<String>.of(_participants);
    return (result) => SessionService().recordSession(
      groupId: group.id,
      gameType: widget.game.id,
      participants: participants,
      result: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('참가자 입력'),
        actions: [
          ShrinkButton(
            onPressed: _showRecentParticipantsSheet,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.history, color: kColorPrimary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참가자 ${_participants.length}명 '
              '(최소 ${widget.game.minParticipants}명 · 최대 ${widget.game.maxParticipants}명)',
              style: kTextBody2,
            ),
            const SizedBox(height: kSpacingSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: InputDecoration(
                      hintText: '이름 입력',
                      errorText: _errorText,
                    ),
                    onSubmitted: (_) => _addParticipant(),
                  ),
                ),
                const SizedBox(width: kSpacingSm),
                PrimaryButton(onPressed: _addParticipant, child: const Text('추가')),
              ],
            ),
            const SizedBox(height: kSpacingMd),
            Expanded(
              child: _participants.isEmpty
                  ? const Center(child: Text('참가자를 추가해주세요'))
                  : ListView.builder(
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_participants[index]),
                          trailing: ShrinkButton(
                            onPressed: () => _removeParticipant(index),
                            child: const Padding(
                              padding: EdgeInsets.all(kSpacingSm),
                              child: Icon(
                                Icons.delete_outline,
                                color: kColorTextSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: kSpacingMd),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _participants.length >= widget.game.minParticipants
                    ? () {
                        RecentParticipantsService().recordPlayed(
                          widget.group?.id,
                          _participants,
                        );
                        Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (context) => widget.game
                                .buildAfterParticipants(
                                  context,
                                  _participants,
                                  onResult: _buildOnResult(),
                                ),
                          ),
                        );
                      }
                    : null,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
