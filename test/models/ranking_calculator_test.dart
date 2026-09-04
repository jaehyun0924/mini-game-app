import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/models/game_outcome.dart';
import 'package:mini_game_app/models/ranking_calculator.dart';
import 'package:mini_game_app/models/session.dart';

SessionModel _session(
  String gameType,
  Map<String, bool> specialByParticipant,
) {
  return SessionModel(
    id: 'id',
    gameType: gameType,
    participants: specialByParticipant.keys.toList(),
    outcomesByParticipant: {
      for (final entry in specialByParticipant.entries)
        entry.key: GameOutcome(
          label: entry.value ? '당첨' : '통과',
          isSpecial: entry.value,
        ),
    },
    hostId: 'host',
  );
}

void main() {
  group('computeRanking', () {
    test('참여 횟수와 특별 결과 횟수를 참가자별로 합산하고 승 수 내림차순으로 정렬한다', () {
      final sessions = [
        _session('ladder', {'A': false, 'B': true}),
        _session('roulette', {'A': true, 'B': false}),
        _session('lotto_draw', {'A': false, 'B': false}),
      ];

      final ranking = computeRanking(sessions);

      final a = ranking.firstWhere((e) => e.participant == 'A');
      final b = ranking.firstWhere((e) => e.participant == 'B');
      expect(a.playedCount, 3);
      expect(a.specialCount, 1);
      expect(a.winCount, 2);
      expect(b.playedCount, 3);
      expect(b.specialCount, 1);
      expect(b.winCount, 2);
      // 승 수가 같으면 순서가 바뀌지 않아야 하는 건 아니지만, 최소한 둘 다
      // 리스트에 있고 정렬 기준(승 수 내림차순)이 깨지지 않았는지만 확인한다.
      expect(ranking.length, 2);
      expect(
        ranking[0].winCount >= ranking[1].winCount,
        isTrue,
      );
    });

    test('gameType을 지정하면 그 게임의 세션만 집계한다', () {
      final sessions = [
        _session('ladder', {'A': true}),
        _session('roulette', {'A': false}),
      ];

      final ranking = computeRanking(sessions, gameType: 'roulette');

      expect(ranking.length, 1);
      expect(ranking.single.playedCount, 1);
      expect(ranking.single.specialCount, 0);
    });

    test('세션이 없으면 빈 리스트를 반환한다', () {
      expect(computeRanking([]), isEmpty);
    });
  });

  group('computeGameCounts', () {
    test('한 참가자가 참여한 세션을 게임 종류별로 센다', () {
      final sessions = [
        _session('ladder', {'A': true, 'B': false}),
        _session('ladder', {'A': false}),
        _session('roulette', {'A': true}),
        _session('roulette', {'B': true}),
      ];

      final counts = computeGameCounts(sessions, 'A');

      expect(counts, {'ladder': 2, 'roulette': 1});
    });

    test('참여하지 않은 참가자는 빈 맵을 반환한다', () {
      final sessions = [_session('ladder', {'A': true})];
      expect(computeGameCounts(sessions, 'C'), isEmpty);
    });
  });
}
