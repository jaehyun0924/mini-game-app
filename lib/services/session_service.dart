import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_game_app/models/session.dart';
import 'package:mini_game_app/models/session_result.dart';

/// groups/{groupId}/sessions 하위 컬렉션을 다룬다 — 게임 결과 기록과,
/// 랭킹/개인 통계 화면이 공용으로 구독하는 조회를 담당한다.
class SessionService {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _sessionsOf(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('sessions');
  }

  Future<void> recordSession({
    required String groupId,
    required String gameType,
    required List<String> participants,
    required SessionResult result,
  }) {
    return _sessionsOf(groupId).add({
      'gameType': gameType,
      'participants': participants,
      'result': {
        for (final entry in result.outcomesByParticipant.entries)
          entry.key: {
            'label': entry.value.label,
            'isSpecial': entry.value.isSpecial,
          },
      },
      'hostId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 그룹 안의 모든 세션. 연구실 단위 소규모 그룹 기준으로는 클라이언트에서
  /// 전체를 구독해 직접 집계해도 충분하다 — Cloud Functions로 별도 집계본을
  /// 만드는 건 그룹 규모가 훨씬 커졌을 때 고려할 최적화.
  Stream<List<SessionModel>> streamSessions(String groupId) {
    return _sessionsOf(groupId).snapshots().map(
      (snap) => snap.docs.map(SessionModel.fromSnapshot).toList(),
    );
  }
}
