import 'dart:math';

import 'ladder_constants.dart';

const int kLadderRowCount = 10;

/// 사다리의 다리(가로선) 하나. row 높이에서 column번째와 column+1번째 세로선을 잇는다.
class LadderRung {
  final int row;
  final int column;

  const LadderRung({required this.row, required this.column});

  @override
  bool operator ==(Object other) =>
      other is LadderRung && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}

/// 경로 위의 한 지점. column은 세로선 번호(정수값이지만 보간을 위해 double),
/// row는 0(맨 위)~rowCount(맨 아래) 사이의 연속값이며, 다리를 건너는 지점은 row+0.5로 표현한다.
class LadderPathPoint {
  final double column;
  final double row;

  const LadderPathPoint({required this.column, required this.row});
}

/// 사다리 구조 데이터. rungs로 그리기 위한 좌표를,
/// resultMapping으로 각 참가자의 최종 도착 위치를 표현한다.
class LadderStructure {
  final int participantCount;
  final int rowCount;
  final List<LadderRung> rungs;

  /// resultMapping[i] = i번째 참가자가 도착하는 세로선 번호
  final List<int> resultMapping;

  const LadderStructure({
    required this.participantCount,
    required this.rowCount,
    required this.rungs,
    required this.resultMapping,
  });

  /// participantIndex번째 참가자가 사다리를 타고 내려가는 전체 경로(꺾이는 지점 포함).
  List<LadderPathPoint> pathFor(int participantIndex) {
    return LadderGenerator.tracePath(
      participantCount: participantCount,
      rowCount: rowCount,
      rungs: rungs,
      startColumn: participantIndex,
    );
  }
}

class LadderGenerator {
  const LadderGenerator._();

  static LadderStructure generate({
    required int participantCount,
    int rowCount = kLadderRowCount,
    Random? random,
  }) {
    if (participantCount < kMinParticipants ||
        participantCount > kMaxParticipants) {
      throw ArgumentError(
        '참가자는 $kMinParticipants명 이상 $kMaxParticipants명 이하여야 합니다',
      );
    }

    final rng = random ?? Random();
    // grid[row][column] == true면 column과 column+1 세로선 사이에 다리가 있다는 뜻.
    final grid = List.generate(
      rowCount,
      (_) => List<bool>.filled(participantCount - 1, false),
    );

    // 1) 먼저 최소 연결을 보장하는 뼈대를 놓는다: 모든 구간(gap)에 다리를 하나씩,
    //    양 끝 열은 다리를 하나 더 놓아서 처음부터 "완전히 분리된 구간"이나
    //    "다리가 하나도 없는 일직선 열"이 생길 수 없게 한다.
    _seedMinimumConnections(grid, rowCount, participantCount, rng);

    // 2) 그 위에 무작위로 다리를 더 추가해서 밀도를 높인다.
    _addRandomDensity(grid, rowCount, participantCount, rng);

    final rungs = <LadderRung>[
      for (var row = 0; row < rowCount; row++)
        for (var column = 0; column < participantCount - 1; column++)
          if (grid[row][column]) LadderRung(row: row, column: column),
    ];

    final resultMapping = List<int>.generate(participantCount, (start) {
      final path = tracePath(
        participantCount: participantCount,
        rowCount: rowCount,
        rungs: rungs,
        startColumn: start,
      );
      return path.last.column.round();
    });

    return LadderStructure(
      participantCount: participantCount,
      rowCount: rowCount,
      rungs: rungs,
      resultMapping: resultMapping,
    );
  }

  /// startColumn에서 출발해 사다리를 내려가는 경로를, 방향이 꺾이는 지점마다
  /// 좌표를 남겨가며 계산한다. resultMapping 계산과 실제 경로 애니메이션이
  /// 이 함수 하나를 공유하므로 이동 규칙이 두 군데서 어긋날 일이 없다.
  static List<LadderPathPoint> tracePath({
    required int participantCount,
    required int rowCount,
    required List<LadderRung> rungs,
    required int startColumn,
  }) {
    final rungSet = rungs.toSet();
    var column = startColumn.toDouble();
    final points = <LadderPathPoint>[LadderPathPoint(column: column, row: 0)];

    for (var row = 0; row < rowCount; row++) {
      final currentColumn = column.round();
      final turnRow = row + 0.5;

      if (currentColumn < participantCount - 1 &&
          rungSet.contains(LadderRung(row: row, column: currentColumn))) {
        points.add(LadderPathPoint(column: column, row: turnRow));
        column += 1;
        points.add(LadderPathPoint(column: column, row: turnRow));
      } else if (currentColumn > 0 &&
          rungSet.contains(
            LadderRung(row: row, column: currentColumn - 1),
          )) {
        points.add(LadderPathPoint(column: column, row: turnRow));
        column -= 1;
        points.add(LadderPathPoint(column: column, row: turnRow));
      }
    }

    points.add(LadderPathPoint(column: column, row: rowCount.toDouble()));
    return points;
  }

  /// 모든 구간(gap, 즉 세로열 쌍)에 다리를 최소 2개씩 심는다.
  /// 1) 먼저 gap마다 하나씩: gap번째 다리는 (gap % rowCount)행에 놓는데, rowCount가
  ///    2 이상이면 인접한 두 gap은 항상 서로 다른 행에 놓이므로(예: gap=3은 3행,
  ///    gap=4는 4행) 같은 행에서 다리가 겹칠 걱정 없이 항상 안전하다.
  /// 2) 그 다음 모든 gap에 대해 _tryAddRung으로 하나씩 더 추가해서 2개를 채운다.
  ///    (예전에는 이 2단계를 양 끝 gap에만 해줬는데, 그러면 안쪽 gap은 1단계에서 받은
  ///    1개뿐이고 그 이후는 _addRandomDensity의 확률(동전 던지기)에 맡겨져서 운이
  ///    나쁘면 다리가 1개인 채로 남는 문제가 있었다.)
  static void _seedMinimumConnections(
    List<List<bool>> grid,
    int rowCount,
    int participantCount,
    Random rng,
  ) {
    final gapCount = participantCount - 1;
    if (gapCount <= 0) return;

    for (var gap = 0; gap < gapCount; gap++) {
      grid[gap % rowCount][gap] = true;
    }

    for (var gap = 0; gap < gapCount; gap++) {
      _tryAddRung(grid, rowCount, gapCount, gap, rng);
    }
  }

  /// 뼈대 위에 무작위로 다리를 더 추가해서 밀도를 높인다. 이미 다리가 있거나
  /// 같은 행의 바로 옆 칸이 채워져 있으면 건너뛰므로 겹칠 일이 없다.
  static void _addRandomDensity(
    List<List<bool>> grid,
    int rowCount,
    int participantCount,
    Random rng,
  ) {
    final gapCount = participantCount - 1;
    for (var row = 0; row < rowCount; row++) {
      for (var gap = 0; gap < gapCount; gap++) {
        if (grid[row][gap]) continue;
        final leftOccupied = gap > 0 && grid[row][gap - 1];
        final rightOccupied = gap < gapCount - 1 && grid[row][gap + 1];
        if (leftOccupied || rightOccupied) continue;
        if (rng.nextBool()) {
          grid[row][gap] = true;
        }
      }
    }
  }

  /// gap 위치(해당 세로선과 그 오른쪽 세로선 사이)에, 같은 행에서 이웃한 다리와
  /// 겹치지 않는 빈 행을 찾아 다리를 하나 추가한다. 추가에 성공하면 true.
  static bool _tryAddRung(
    List<List<bool>> grid,
    int rowCount,
    int gapCount,
    int gap,
    Random rng,
  ) {
    final rows = List<int>.generate(rowCount, (i) => i)..shuffle(rng);
    for (final row in rows) {
      if (grid[row][gap]) continue;
      final leftOccupied = gap > 0 && grid[row][gap - 1];
      final rightOccupied = gap < gapCount - 1 && grid[row][gap + 1];
      if (leftOccupied || rightOccupied) continue;
      grid[row][gap] = true;
      return true;
    }
    return false;
  }
}
