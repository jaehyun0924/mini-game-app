import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/models/session_result.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/number_stepper.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

import '../mini_game.dart';

/// 참가자 중 몇 명을 뽑을지(당첨 인원 수)만 입력받는 공용 화면. 제비뽑기와
/// 로또뽑기 둘 다 "참가자 전원 중 N명을 무작위로 고른다"는 흐름은 같고,
/// 그 N을 GameSetup에 담는 방식(제비뽑기는 outcomes 라벨 배정, 로또뽑기는
/// pickCount)만 게임마다 달라서 그 조립 로직만 [buildSetup] 콜백으로 받는다.
class WinnerCountSetupScreen extends StatefulWidget {
  final MiniGame game;
  final List<String> participants;
  final String question;
  final String submitLabel;
  final GameSetup Function(List<String> participants, int winnerCount)
  buildSetup;
  final GameResultCallback? onResult;

  const WinnerCountSetupScreen({
    super.key,
    required this.game,
    required this.participants,
    required this.question,
    required this.submitLabel,
    required this.buildSetup,
    this.onResult,
  });

  @override
  State<WinnerCountSetupScreen> createState() =>
      _WinnerCountSetupScreenState();
}

class _WinnerCountSetupScreenState extends State<WinnerCountSetupScreen> {
  int _winnerCount = 1;

  void _submit() {
    final setup = widget.buildSetup(widget.participants, _winnerCount);
    Navigator.push(
      context,
      AppPageRoute(
        builder: (context) => widget.game.playScreen(
          context,
          setup,
          onResult: widget.onResult,
        ),
      ),
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
            Text(widget.question, style: kTextBody2),
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
                child: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
