import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_app/games/common/participant_setup_screen.dart';
import 'package:mini_game_app/games/game_registry.dart';
import 'package:mini_game_app/screens/feedback_screen.dart';
import 'package:mini_game_app/screens/group_home_screen.dart';
import 'package:mini_game_app/screens/profile_screen.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미니게임'),
        actions: [
          ShrinkButton(
            onPressed: () {
              Navigator.push(
                context,
                AppPageRoute(builder: (context) => const GroupHomeScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.group_outlined, color: kColorPrimary),
            ),
          ),
          ShrinkButton(
            onPressed: () {
              Navigator.push(
                context,
                AppPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.lightbulb_outline, color: kColorPrimary),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: kSpacingMd),
            child: Center(child: _ProfileBadge()),
          ),
        ],
      ),
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
                      builder: (context) => ParticipantSetupScreen(game: game),
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

/// "닉네임: ID" 형태로 현재 로그인된 계정을 보여주는 표시줄. 탭하면 닉네임을
/// 바꿀 수 있는 내 정보 화면으로 이동한다. ID는 한 줄에 다 보여주기엔 길어서
/// (익명 계정 uid, 28자) 여기서는 앞부분만 잘라 보여주고, 전체 ID와 복사
/// 기능은 ProfileScreen에서 확인한다.
///
/// FirebaseAuth 접근을 build 안에서 바로 하지 않고 Future 안에 넣어둔 이유:
/// main()에서 항상 로그인을 먼저 끝내고 HomeScreen을 띄우니 실제 앱에서는
/// 문제가 없지만, Firebase를 초기화하지 않는 위젯 테스트에서 홈 화면을 바로
/// pump하면 build 도중 동기적으로 예외가 나면서 화면 전체가 깨진다. Future
/// 안에서 던지면 FutureBuilder가 에러를 조용히 흡수하고 빈 자리로 넘어간다.
class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge();

  Future<(String uid, String nickname)> _load() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final nicknames = await UserService().getNicknames([uid]);
    return (uid, nicknames[uid] ?? '...');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(String uid, String nickname)>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final (uid, nickname) = snapshot.data!;
        final shortId = uid.length > 8 ? '${uid.substring(0, 8)}…' : uid;

        return ShrinkButton(
          onPressed: () {
            Navigator.push(
              context,
              AppPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMd,
              vertical: kSpacingSm,
            ),
            decoration: BoxDecoration(
              color: kColorPrimaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$nickname: $shortId', style: kTextCaption),
          ),
        );
      },
    );
  }
}
