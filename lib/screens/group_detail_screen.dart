import 'package:firebase_auth/firebase_auth.dart';
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
          final isOwner =
              group.ownerId == FirebaseAuth.instance.currentUser?.uid;
          return Padding(
            padding: const EdgeInsets.all(kSpacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: kTextHeading2),
                const SizedBox(height: kSpacingLg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: Text('초대 코드', style: kTextBody2)),
                    if (isOwner)
                      TextButton(
                        onPressed: () => _reissueCode(context, group),
                        child: const Text('코드 재발급'),
                      ),
                  ],
                ),
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
                const SizedBox(height: kSpacingMd),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: kColorError),
                    onPressed: () => isOwner
                        ? _deleteGroup(context, group)
                        : _leaveGroup(context, group),
                    child: Text(isOwner ? '그룹 삭제' : '그룹 탈퇴'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kColorError),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _reissueCode(BuildContext context, GroupModel group) async {
    final confirmed = await _confirm(
      context,
      title: '초대 코드를 재발급할까요?',
      message: '기존 코드(${group.inviteCode})는 더 이상 사용할 수 없어요.',
      confirmLabel: '재발급',
    );
    if (!confirmed) return;

    try {
      await GroupService().reissueInviteCode(group);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재발급에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  Future<void> _leaveGroup(BuildContext context, GroupModel group) async {
    final confirmed = await _confirm(
      context,
      title: '그룹을 탈퇴할까요?',
      message: '탈퇴하면 다시 초대 코드로 참여해야 해요.',
      confirmLabel: '탈퇴',
    );
    if (!confirmed) return;

    try {
      await GroupService().leaveGroup(group.id);
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  Future<void> _deleteGroup(BuildContext context, GroupModel group) async {
    final confirmed = await _confirm(
      context,
      title: '그룹을 삭제할까요?',
      message: '삭제하면 되돌릴 수 없고, 그룹의 게임 기록도 더 이상 볼 수 없게 돼요.',
      confirmLabel: '삭제',
    );
    if (!confirmed) return;

    try {
      await GroupService().deleteGroup(group.id);
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했어요. 다시 시도해주세요')),
      );
    }
  }
}
