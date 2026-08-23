import 'package:flutter/material.dart';
import 'package:mini_game_app/games/ladder/ladder_participant_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미니게임')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
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
