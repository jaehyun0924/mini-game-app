import 'ranking_entry.dart';
import 'session.dart';

/// sessions 목록에서 참가자별 승/패, 특별 결과(예: 커피 사기) 횟수를 집계한다.
/// [gameType]을 주면 그 게임만, 아니면 그룹 전체 게임을 합쳐서 집계한다.
/// 순위는 승 수 내림차순, 같으면 참여 횟수 내림차순으로 매긴다.
List<RankingEntry> computeRanking(List<SessionModel> sessions, {String? gameType}) {
  final playedCount = <String, int>{};
  final specialCount = <String, int>{};

  for (final session in sessions) {
    if (gameType != null && session.gameType != gameType) continue;
    for (final entry in session.outcomesByParticipant.entries) {
      playedCount[entry.key] = (playedCount[entry.key] ?? 0) + 1;
      if (entry.value.isSpecial) {
        specialCount[entry.key] = (specialCount[entry.key] ?? 0) + 1;
      }
    }
  }

  final entries = [
    for (final participant in playedCount.keys)
      RankingEntry(
        participant: participant,
        playedCount: playedCount[participant]!,
        specialCount: specialCount[participant] ?? 0,
      ),
  ];

  entries.sort((a, b) {
    final winCompare = b.winCount.compareTo(a.winCount);
    if (winCompare != 0) return winCompare;
    return b.playedCount.compareTo(a.playedCount);
  });

  return entries;
}

/// 한 참가자가 게임별로 몇 번씩 참여했는지. 개인 통계 화면의 "게임별 참여 횟수"용.
Map<String, int> computeGameCounts(List<SessionModel> sessions, String participant) {
  final counts = <String, int>{};
  for (final session in sessions) {
    if (!session.outcomesByParticipant.containsKey(participant)) continue;
    counts[session.gameType] = (counts[session.gameType] ?? 0) + 1;
  }
  return counts;
}
