import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/ladder/ladder_generator.dart';

void main() {
  group('LadderGenerator', () {
    test('5명 참가자의 사다리를 생성하면 결과가 1:1로 매핑된다', () {
      final structure = LadderGenerator.generate(
        participantCount: 5,
        random: Random(42),
      );

      expect(structure.participantCount, 5);
      expect(structure.resultMapping.length, 5);
      expect(structure.resultMapping.toSet(), {0, 1, 2, 3, 4});
    });

    test('같은 행에서 인접한 세로선끼리 다리가 겹치지 않는다', () {
      for (var seed = 0; seed < 20; seed++) {
        final structure = LadderGenerator.generate(
          participantCount: 8,
          random: Random(seed),
        );

        final columnsByRow = <int, List<int>>{};
        for (final rung in structure.rungs) {
          columnsByRow.putIfAbsent(rung.row, () => []).add(rung.column);
        }

        for (final columns in columnsByRow.values) {
          final sorted = columns..sort();
          for (var i = 1; i < sorted.length; i++) {
            expect(
              sorted[i] - sorted[i - 1],
              greaterThanOrEqualTo(2),
              reason: '같은 행에서 인접한 세로선에 다리가 겹치면 안 된다',
            );
          }
        }
      }
    });

    test('최소 인원(2명)에서도 유효한 사다리를 생성한다', () {
      final structure = LadderGenerator.generate(
        participantCount: 2,
        random: Random(1),
      );
      expect(structure.resultMapping.toSet(), {0, 1});
    });

    test('참가자가 2명 미만이면 예외를 던진다', () {
      expect(
        () => LadderGenerator.generate(participantCount: 1),
        throwsArgumentError,
      );
    });

    test('참가자가 최대 인원(10명)을 초과하면 예외를 던진다', () {
      expect(
        () => LadderGenerator.generate(participantCount: 11),
        throwsArgumentError,
      );
    });

    test('2명부터 10명까지 항상 순열(bijection)이 성립한다', () {
      for (var n = 2; n <= 10; n++) {
        for (var seed = 0; seed < 10; seed++) {
          final structure = LadderGenerator.generate(
            participantCount: n,
            random: Random(seed * 100 + n),
          );
          expect(structure.resultMapping.toSet().length, n);
        }
      }
    });

    test('pathFor의 마지막 지점이 resultMapping과 일치한다', () {
      final structure = LadderGenerator.generate(
        participantCount: 5,
        random: Random(3),
      );

      for (var i = 0; i < structure.participantCount; i++) {
        final path = structure.pathFor(i);
        expect(path.first.column, i.toDouble());
        expect(path.first.row, 0);
        expect(path.last.row, structure.rowCount.toDouble());
        expect(path.last.column.round(), structure.resultMapping[i]);
      }
    });

    test('경로는 항상 세로선 범위(0~참가자수-1) 안에서만 움직인다', () {
      for (var seed = 0; seed < 10; seed++) {
        final structure = LadderGenerator.generate(
          participantCount: 6,
          random: Random(seed),
        );
        for (var i = 0; i < structure.participantCount; i++) {
          for (final point in structure.pathFor(i)) {
            expect(point.column, greaterThanOrEqualTo(0));
            expect(point.column, lessThanOrEqualTo(structure.participantCount - 1));
          }
        }
      }
    });

    test('모든 열은 다리를 최소 2개 갖는다 (일직선으로만 내려가는 줄 없음)', () {
      for (var n = 2; n <= 10; n++) {
        for (var seed = 0; seed < 15; seed++) {
          final structure = LadderGenerator.generate(
            participantCount: n,
            random: Random(seed * 10 + n),
          );

          final degree = List<int>.filled(n, 0);
          for (final rung in structure.rungs) {
            degree[rung.column]++;
            degree[rung.column + 1]++;
          }

          for (var column = 0; column < n; column++) {
            expect(
              degree[column],
              greaterThanOrEqualTo(2),
              reason: 'participantCount=$n seed=$seed column=$column',
            );
          }
        }
      }
    });

    test('모든 구간(gap)에는 다리가 최소 1개 있어 열 그룹이 분리되지 않는다', () {
      for (var n = 2; n <= 10; n++) {
        for (var seed = 0; seed < 15; seed++) {
          final structure = LadderGenerator.generate(
            participantCount: n,
            random: Random(seed * 10 + n),
          );

          final gapHasRung = List<bool>.filled(n - 1, false);
          for (final rung in structure.rungs) {
            gapHasRung[rung.column] = true;
          }

          expect(
            gapHasRung.every((connected) => connected),
            isTrue,
            reason: 'participantCount=$n seed=$seed',
          );
        }
      }
    });
  });
}
