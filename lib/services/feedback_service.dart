import 'package:cloud_firestore/cloud_firestore.dart';

/// "새 게임 제안하기" 폼 내용을 Firestore feedback 컬렉션에 저장한다.
/// 조회는 앱이 아니라 Firebase 콘솔에서 직접 한다 (firestore.rules 참고).
class FeedbackService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('feedback');

  Future<void> submitGameSuggestion({
    required String gameName,
    required String description,
  }) {
    return _collection.add({
      'gameName': gameName,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
