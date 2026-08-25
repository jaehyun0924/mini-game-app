import 'package:flutter/material.dart';
import 'package:mini_game_app/games/common/participant_setup_screen.dart';
import 'package:mini_game_app/games/game_registry.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미니게임')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final game in kAllGames)
              PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    AppPageRoute(
                      builder: (context) =>
                          ParticipantSetupScreen(game: game),
                    ),
                  );
                },
                child: Text(game.name),
              ),
          ],
        ),
      ),
    );
  }
}
