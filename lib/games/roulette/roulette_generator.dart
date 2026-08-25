import 'dart:math';

import 'roulette_constants.dart';

class RouletteGenerator {
  const RouletteGenerator._();

  /// participantCount명 중 당첨(벌칙) 대상 1명의 인덱스를 무작위로 뽑는다.
  static int generate({required int participantCount, Random? random}) {
    if (participantCount < kRouletteMinParticipants ||
        participantCount > kRouletteMaxParticipants) {
      throw ArgumentError(
        '참가자는 $kRouletteMinParticipants명 이상 $kRouletteMaxParticipants명 이하여야 합니다',
      );
    }

    final rng = random ?? Random();
    return rng.nextInt(participantCount);
  }
}
