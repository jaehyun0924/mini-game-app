import 'package:flutter/material.dart';
import 'package:mini_game_app/games/ladder/ladder_participant_screen.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미니게임')),
      body: Center(
        child: PrimaryButton(
          onPressed: () {
            Navigator.push(
              context,
              AppPageRoute(
                builder: (context) => const LadderParticipantScreen(),
              ),
            );
          },
          child: const Text('사다리타기'),
        ),
      ),
    );
  }
}
