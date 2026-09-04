import 'package:flutter/material.dart';
import 'package:mini_game_app/games/common/participant_setup_screen.dart';
import 'package:mini_game_app/games/game_registry.dart';
import 'package:mini_game_app/models/group.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// 그룹 안에서 플레이할 게임을 고르는 화면. 홈 화면의 게임 목록과 내용은
/// 같지만, group을 ParticipantSetupScreen까지 들고 가서 게임이 끝났을 때
/// 결과가 이 그룹의 sessions에 자동으로 기록되게 한다는 점이 다르다.
class GroupGameSelectScreen extends StatelessWidget {
  final GroupModel group;

  const GroupGameSelectScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${group.name} · 게임하기')),
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
                          ParticipantSetupScreen(game: game, group: group),
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
