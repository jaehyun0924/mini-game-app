import 'package:flutter/material.dart';
import 'package:mini_game_app/models/group.dart';
import 'package:mini_game_app/screens/group_create_screen.dart';
import 'package:mini_game_app/screens/group_detail_screen.dart';
import 'package:mini_game_app/screens/group_join_screen.dart';
import 'package:mini_game_app/services/group_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/page_transitions.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

/// 내가 속한 그룹 목록. 그룹을 탭하면 그 그룹의 상세(초대 코드/멤버 목록)로 이동한다.
class GroupHomeScreen extends StatelessWidget {
  const GroupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 그룹')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<GroupModel>>(
                stream: GroupService().streamMyGroups(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final groups = snapshot.data!;
                  if (groups.isEmpty) {
                    return const Center(
                      child: Text('아직 속한 그룹이 없어요', style: kTextBody2),
                    );
                  }
                  return ListView.separated(
                    itemCount: groups.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: kSpacingSm),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return ShrinkButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (context) =>
                                  GroupDetailScreen(groupId: group.id),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(kSpacingMd),
                          decoration: BoxDecoration(
                            color: kColorSurface,
                            borderRadius: BorderRadius.circular(kRadiusMd),
                            border: Border.all(color: kColorBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(group.name, style: kTextTitle),
                              ),
                              Text(
                                '${group.memberIds.length}명',
                                style: kTextBody2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: kSpacingMd),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => Navigator.push(
                      context,
                      AppPageRoute(builder: (context) => const GroupJoinScreen()),
                    ),
                    child: const Text('코드로 참여하기'),
                  ),
                ),
                const SizedBox(width: kSpacingSm),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => Navigator.push(
                      context,
                      AppPageRoute(
                        builder: (context) => const GroupCreateScreen(),
                      ),
                    ),
                    child: const Text('그룹 만들기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
