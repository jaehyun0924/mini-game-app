import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_game_app/games/ladder/ladder_board.dart';
import 'package:mini_game_app/games/ladder/ladder_generator.dart';
import 'package:mini_game_app/games/ladder/ladder_path_overlay.dart';
import 'package:mini_game_app/games/roulette/roulette_wheel.dart';
import 'package:mini_game_app/models/ranking_entry.dart';
import 'package:mini_game_app/widgets/ranking_list.dart';

/// 목표#2(최적화) 체크포인트 확인용 프레임 성능 측정. 앱 실행 경로(lib/)에는
/// 포함되지 않고, `flutter drive`로만 실행되는 개발자 전용 스크립트다.
///
/// 실행 방법:
///   flutter drive --driver=test_driver/perf_driver.dart \
///     --target=integration_test/animation_perf_test.dart -d chrome --profile
///
/// 실행 후 build/animation_perf_timeline_summary.json 에 각 시나리오별
/// average_frame_build_time_millis / worst_frame_build_time_millis /
/// missed_frame_build_budget_count 가 기록된다. 60fps 기준 한 프레임 예산은
/// 16ms이므로, worst 값이 이를 크게 넘거나 missed 카운트가 0보다 크면
/// 그 화면에서 프레임 드롭이 있다는 뜻이다.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('사다리타기 경로 추적 애니메이션', (tester) async {
    final structure = LadderGenerator.generate(
      participantCount: 6,
      random: Random(42),
    );
    int? selected;
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 480,
            child: StatefulBuilder(
              builder: (context, setter) {
                setState = setter;
                return Stack(
                  children: [
                    LadderBoard(structure: structure),
                    LadderPathOverlay(
                      structure: structure,
                      selectedParticipant: selected,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    // 사다리 자체가 그려지는 초기 연출(kRevealDuration)은 측정 대상이
    // 아니므로 먼저 끝나도록 흘려보낸다.
    await tester.pumpAndSettle();

    await binding.traceAction(() async {
      setState(() => selected = 0);
      await tester.pumpAndSettle();
    }, reportKey: 'ladder_path_timeline');
  });

  testWidgets('룰렛 회전 애니메이션', (tester) async {
    final labels = List.generate(8, (i) => '참가자$i');
    int? target;
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 320,
            child: StatefulBuilder(
              builder: (context, setter) {
                setState = setter;
                return RouletteWheel(labels: labels, targetSectorIndex: target);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await binding.traceAction(() async {
      setState(() => target = 3);
      await tester.pumpAndSettle();
    }, reportKey: 'roulette_spin_timeline');
  });

  testWidgets('랭킹 리스트 재배열 애니메이션', (tester) async {
    List<RankingEntry> entries = [
      for (var i = 0; i < 10; i++)
        RankingEntry(participant: '참가자$i', playedCount: 10, specialCount: i),
    ];
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setter) {
              setState = setter;
              return SingleChildScrollView(child: RankingList(entries: entries));
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await binding.traceAction(() async {
      // 순위가 완전히 뒤집히는, 가장 큰 폭의 재배열을 기준으로 측정한다.
      setState(() => entries = entries.reversed.toList());
      await tester.pumpAndSettle();
    }, reportKey: 'ranking_reorder_timeline');
  });
}
