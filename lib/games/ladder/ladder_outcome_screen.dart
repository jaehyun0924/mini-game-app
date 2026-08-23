import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';

import 'ladder_outcome.dart';
import 'ladder_result_screen.dart';

/// 참가자 수만큼 도착 지점 결과(당첨/꽝/커피사기 등)를 입력받는 화면.
class LadderOutcomeScreen extends StatefulWidget {
  final List<String> participants;

  const LadderOutcomeScreen({super.key, required this.participants});

  @override
  State<LadderOutcomeScreen> createState() => _LadderOutcomeScreenState();
}

class _LadderOutcomeScreenState extends State<LadderOutcomeScreen> {
  static const String _defaultLabel = '통과';

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<bool> _isSpecial;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (var i = 0; i < widget.participants.length; i++)
        TextEditingController(text: _defaultLabel),
    ];
    _focusNodes = [
      for (var i = 0; i < widget.participants.length; i++) FocusNode(),
    ];
    _isSpecial = List<bool>.filled(widget.participants.length, false);
    // 입력 상태에 따라 "사다리 만들기" 버튼 활성화 여부를 바로 갱신하기 위해 구독한다.
    for (final controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
    // 기본값("통과")이 그대로 남아있는 칸을 누르면, 직접 입력할 수 있도록 비워준다.
    // 반대로 비워둔 채 아무것도 입력하지 않고 다른 칸으로 넘어가면 다시 "통과"로 되돌린다.
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          if (_controllers[i].text == _defaultLabel) {
            _controllers[i].clear();
          }
        } else {
          if (_controllers[i].text.trim().isEmpty) {
            _controllers[i].text = _defaultLabel;
          }
        }
      });
    }
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool get _allFilled =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  void _submit() {
    final outcomes = [
      for (var i = 0; i < _controllers.length; i++)
        LadderOutcome(
          label: _controllers[i].text.trim(),
          isSpecial: _isSpecial[i],
        ),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LadderResultScreen(
          participants: widget.participants,
          outcomes: outcomes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결과 입력')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('도착 지점마다 나올 결과를 입력해주세요', style: kTextBody2),
            const SizedBox(height: kSpacingSm),
            Expanded(
              child: ListView.separated(
                itemCount: _controllers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: kSpacingSm),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text('결과 ${index + 1}', style: kTextBody2),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          decoration: const InputDecoration(
                            hintText: '예: 커피사기, 꽝, 당첨',
                          ),
                        ),
                      ),
                      const SizedBox(width: kSpacingSm),
                      Checkbox(
                        value: _isSpecial[index],
                        onChanged: (value) {
                          setState(() => _isSpecial[index] = value ?? false);
                        },
                      ),
                      Text('특별', style: kTextBody2),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: kSpacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _allFilled ? _submit : null,
                child: const Text('사다리 만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
