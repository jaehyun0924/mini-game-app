import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_app/games/game_registry.dart';
import 'package:mini_game_app/models/ranking_calculator.dart';
import 'package:mini_game_app/models/session.dart';
import 'package:mini_game_app/services/session_service.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';

/// 내 승/패, 게임별 참여 횟수. 그룹 랭킹과 같은 세션 스트림/집계 로직
/// (computeRanking/computeGameCounts)을 재사용하고, 그 결과에서 "내 이름"에
/// 해당하는 항목만 뽑아 보여준다.
///
/// 참가자 이름은 게임 시작할 때 자유롭게 입력하는 텍스트라 uid와 직접
/// 연결돼 있지 않다. 그래서 "내 기록"은 내 닉네임과 세션에 기록된 참가자
/// 이름이 일치하는 것으로 판단한다 — 그룹원이 게임할 때 본인 닉네임을 그대로
/// 입력한다고 가정하는 단순한 방식이다.
class MyStatsScreen extends StatelessWidget {
  final String groupId;

  const MyStatsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('내 통계')),
      body: FutureBuilder<Map<String, String>>(
        future: UserService().getNicknames([uid]),
        builder: (context, nicknameSnapshot) {
          if (!nicknameSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final myName = nicknameSnapshot.data![uid];
          if (myName == null) {
            return const Center(
              child: Text('닉네임을 먼저 설정해주세요', style: kTextBody2),
            );
          }

          return StreamBuilder<List<SessionModel>>(
            stream: SessionService().streamSessions(groupId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final sessions = snapshot.data!;
              final ranking = computeRanking(sessions);
              final mine = ranking.where((e) => e.participant == myName);
              final played = mine.isEmpty ? 0 : mine.first.playedCount;
              final wins = mine.isEmpty ? 0 : mine.first.winCount;
              final losses = mine.isEmpty ? 0 : mine.first.specialCount;
              final gameCounts = computeGameCounts(sessions, myName);

              return Padding(
                padding: const EdgeInsets.all(kSpacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$myName님의 기록', style: kTextHeading2),
                    const SizedBox(height: kSpacingLg),
                    Row(
                      children: [
                        _StatTile(label: '참여', value: '$played'),
                        const SizedBox(width: kSpacingSm),
                        _StatTile(label: '승', value: '$wins'),
                        const SizedBox(width: kSpacingSm),
                        _StatTile(label: '패', value: '$losses'),
                      ],
                    ),
                    const SizedBox(height: kSpacingLg),
                    const Text('게임별 참여 횟수', style: kTextBody2),
                    const SizedBox(height: kSpacingSm),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final game in kAllGames)
                            if (gameCounts[game.id] != null)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(game.name, style: kTextBody1),
                                trailing: Text(
                                  '${gameCounts[game.id]}회',
                                  style: kTextBody2,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: kSpacingMd),
        decoration: BoxDecoration(
          color: kColorPrimaryLight,
          borderRadius: BorderRadius.circular(kRadiusMd),
        ),
        child: Column(
          children: [
            Text(value, style: kTextHeading2.copyWith(color: kColorPrimary)),
            const SizedBox(height: kSpacingXs),
            Text(label, style: kTextCaption),
          ],
        ),
      ),
    );
  }
}
