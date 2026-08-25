import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/number_stepper.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

import '../mini_game.dart';

/// 당첨 인원 수만 입력받는 화면. 제비뽑기는 참가자 수만큼 막대를 준비하고
/// 그 중 몇 개를 "당첨"으로 할지만 정하면 되므로, 결과 라벨을 하나하나
/// 입력받는 공용 OutcomeSetupScreen 대신 이 전용 화면을 쓴다.
class StrawDrawSetupScreen extends StatefulWidget {
  final MiniGame game;
  final List<String> participants;

  const StrawDrawSetupScreen({
    super.key,
    required this.game,
    required this.participants,
  });

  @override
  State<StrawDrawSetupScreen> createState() => _StrawDrawSetupScreenState();
}

class _StrawDrawSetupScreenState extends State<StrawDrawSetupScreen> {
  int _winnerCount = 1;

  void _submit() {
    final outcomes = [
      for (var i = 0; i < widget.participants.length; i++)
        GameOutcome(
          label: i < _winnerCount ? '당첨' : '통과',
          isSpecial: i < _winnerCount,
        ),
    ];
    final setup = GameSetup(
      participants: widget.participants,
      outcomes: outcomes,
    );
    Navigator.push(
      context,
      AppPageRoute(builder: (context) => widget.game.playScreen(context, setup)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWinners = widget.participants.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('당첨 인원 설정')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참가자 ${widget.participants.length}명 중 몇 명이 당첨될까요?',
              style: kTextBody2,
            ),
            const SizedBox(height: kSpacingXl),
            Center(
              child: NumberStepper(
                value: _winnerCount,
                min: 1,
                max: maxWinners,
                onChanged: (value) => setState(() => _winnerCount = value),
                label: '당첨 인원',
                suffix: '명',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _submit,
                child: const Text('제비뽑기 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
