import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

import 'ladder_constants.dart';
import 'ladder_outcome_screen.dart';

class LadderParticipantScreen extends StatefulWidget {
  const LadderParticipantScreen({super.key});

  @override
  State<LadderParticipantScreen> createState() =>
      _LadderParticipantScreenState();
}

class _LadderParticipantScreenState extends State<LadderParticipantScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final List<String> _participants = [];
  String? _errorText;

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
    if (_participants.length >= kMaxParticipants) {
      setState(() => _errorText = '최대 $kMaxParticipants명까지 추가할 수 있어요');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('참가자 입력')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참가자 ${_participants.length}명 (최소 $kMinParticipants명 · 최대 $kMaxParticipants명)',
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
                onPressed: _participants.length >= kMinParticipants
                    ? () {
                        Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (context) =>
                                LadderOutcomeScreen(participants: _participants),
                          ),
                        );
                      }
                    : null,
                child: const Text('사다리 만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
