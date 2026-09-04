import 'package:flutter/material.dart';
import 'package:mini_game_app/models/group.dart';
import 'package:mini_game_app/screens/group_game_select_screen.dart';
import 'package:mini_game_app/screens/group_ranking_screen.dart';
import 'package:mini_game_app/screens/my_stats_screen.dart';
import 'package:mini_game_app/services/group_service.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// 그룹 이름/초대 코드/멤버 목록을 보여준다. 그룹 문서를 실시간 구독해서
/// 다른 사람이 참여하면 멤버 목록이 바로 갱신된다.
class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 정보')),
      body: StreamBuilder<GroupModel>(
        stream: GroupService().streamGroup(groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final group = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(kSpacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: kTextHeading2),
                const SizedBox(height: kSpacingLg),
                const Text('초대 코드', style: kTextBody2),
                const SizedBox(height: kSpacingXs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(kSpacingMd),
                  decoration: BoxDecoration(
                    color: kColorPrimaryLight,
                    borderRadius: BorderRadius.circular(kRadiusMd),
                  ),
                  child: Text(
                    group.inviteCode,
                    textAlign: TextAlign.center,
                    style: kTextHeading1.copyWith(
                      color: kColorPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: kSpacingLg),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (context) =>
                                GroupGameSelectScreen(group: group),
                          ),
                        ),
                        child: const Text('게임하기'),
                      ),
                    ),
                    const SizedBox(width: kSpacingSm),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (context) =>
                                GroupRankingScreen(groupId: group.id),
                          ),
                        ),
                        child: const Text('랭킹'),
                      ),
                    ),
                    const SizedBox(width: kSpacingSm),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (context) =>
                                MyStatsScreen(groupId: group.id),
                          ),
                        ),
                        child: const Text('내 통계'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingLg),
                Text('멤버 ${group.memberIds.length}명', style: kTextBody2),
                const SizedBox(height: kSpacingSm),
                Expanded(
                  child: FutureBuilder<Map<String, String>>(
                    // group.memberIds가 바뀌면(참여/탈퇴) StreamBuilder가 새로 빌드되면서
                    // 이 Future도 자동으로 새로 실행된다.
                    future: UserService().getNicknames(group.memberIds),
                    builder: (context, nicknameSnapshot) {
                      final nicknames = nicknameSnapshot.data ?? {};
                      return ListView.separated(
                        itemCount: group.memberIds.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: kColorBorder),
                        itemBuilder: (context, index) {
                          final uid = group.memberIds[index];
                          final name = nicknames[uid] ?? '...';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(name, style: kTextBody1),
                            trailing: uid == group.ownerId
                                ? const Text('방장', style: kTextCaption)
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
