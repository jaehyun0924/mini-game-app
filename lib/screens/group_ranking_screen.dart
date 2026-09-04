import 'package:flutter/material.dart';
import 'package:mini_game_app/models/ranking_calculator.dart';
import 'package:mini_game_app/models/session.dart';
import 'package:mini_game_app/services/session_service.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/widgets/ranking_list.dart';

/// 그룹 안의 모든 세션을 실시간 구독해서 참가자별 승/패를 랭킹으로 보여준다.
/// 게임 실행 → 결과 자동 기록 직후 이 화면이 열려 있으면, 스트림이 갱신되면서
/// 랭킹도 바로 반영된다.
class GroupRankingScreen extends StatelessWidget {
  final String groupId;

  const GroupRankingScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('랭킹')),
      body: StreamBuilder<List<SessionModel>>(
        stream: SessionService().streamSessions(groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ranking = computeRanking(snapshot.data!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kSpacingMd),
            child: RankingList(entries: ranking),
          );
        },
      ),
    );
  }
}
