import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_outcome.dart';

/// groups/{groupId}/sessions/{sessionId} 문서 하나 (게임 한 판의 기록).
class SessionModel {
  final String id;
  final String gameType;
  final List<String> participants;
  final Map<String, GameOutcome> outcomesByParticipant;
  final String hostId;

  const SessionModel({
    required this.id,
    required this.gameType,
    required this.participants,
    required this.outcomesByParticipant,
    required this.hostId,
  });

  factory SessionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final resultData = Map<String, dynamic>.from(data['result'] as Map);
    return SessionModel(
      id: doc.id,
      gameType: data['gameType'] as String,
      participants: List<String>.from(data['participants'] as List),
      outcomesByParticipant: {
        for (final entry in resultData.entries)
          entry.key: GameOutcome(
            label: (entry.value as Map)['label'] as String,
            isSpecial: (entry.value as Map)['isSpecial'] as bool? ?? false,
          ),
      },
      hostId: data['hostId'] as String,
    );
  }
}
