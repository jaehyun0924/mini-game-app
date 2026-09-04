import 'package:flutter/material.dart';
import 'package:mini_game_app/models/ranking_entry.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';

const double _kRowHeight = 64;

/// 순위가 바뀔 때 카드가 새 순번 자리로 부드럽게 미끄러지듯 이동하는 랭킹
/// 리스트. Firestore 스트림은 세션이 추가될 때마다 참가자 목록 전체를
/// 다시 계산해서 내려주기 때문에, AnimatedList(삽입/삭제 애니메이션 위주)보다는
/// 참가자 이름을 키로 삼아 Stack 안에서 AnimatedPositioned로 "다음 순위의
/// 세로 위치"만 보간하는 방식이 더 잘 맞는다 — 위젯이 키로 유지되기만
/// 하면 몇 번째 자식으로 다시 그려지든 이전 위치에서 새 위치로 자연히
/// 애니메이션된다.
class RankingList extends StatelessWidget {
  final List<RankingEntry> entries;

  const RankingList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('아직 기록이 없어요', style: kTextBody2));
    }

    return SizedBox(
      height: entries.length * _kRowHeight,
      child: Stack(
        children: [
          for (var i = 0; i < entries.length; i++)
            AnimatedPositioned(
              key: ValueKey(entries[i].participant),
              duration: kSlowDuration,
              curve: kBounceCurve,
              top: i * _kRowHeight,
              left: 0,
              right: 0,
              height: _kRowHeight,
              child: _RankingRow(rank: i + 1, entry: entries[i]),
            ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final RankingEntry entry;

  const _RankingRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingXs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacingMd,
          vertical: kSpacingSm,
        ),
        decoration: BoxDecoration(
          color: kColorSurface,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: kColorBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: kTextTitle.copyWith(color: kColorPrimary),
              ),
            ),
            Expanded(child: Text(entry.participant, style: kTextBody1)),
            Text(
              '${entry.winCount}승 ${entry.specialCount}패',
              style: kTextBody2,
            ),
          ],
        ),
      ),
    );
  }
}
