import 'package:flutter/material.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/game_setup.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/number_stepper.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

import '../mini_game.dart';

/// 뽑을 당첨자 수만 입력받는 화면. 로또뽑기는 참가자 전원을 공 뽑기 기계에
/// 넣어두고 그 중 몇 명을 뽑을지만 정하면 되므로, 결과 라벨을 하나하나
/// 입력받는 공용 OutcomeSetupScreen 대신 이 전용 화면을 쓴다 — 제비뽑기의
/// StrawDrawSetupScreen과 같은 이유, 같은 구조다.
class LottoDrawSetupScreen extends StatefulWidget {
  final MiniGame game;
  final List<String> participants;

  const LottoDrawSetupScreen({
    super.key,
    required this.game,
    required this.participants,
  });

  @override
  State<LottoDrawSetupScreen> createState() => _LottoDrawSetupScreenState();
}

class _LottoDrawSetupScreenState extends State<LottoDrawSetupScreen> {
  int _winnerCount = 1;

  void _submit() {
    // outcomes 자체는 로또뽑기에서 라벨로 쓰이지 않는다 — 개수(길이)만
    // "몇 명을 뽑을지"를 컴퓨트 단계에 전달하는 용도다.
    final outcomes = List.generate(
      _winnerCount,
      (_) => const GameOutcome(label: '당첨', isSpecial: true),
    );
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
              '참가자 ${widget.participants.length}명 중 몇 명을 뽑을까요?',
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
                child: const Text('공 뽑기 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
