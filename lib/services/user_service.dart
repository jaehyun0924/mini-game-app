import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// users/{uid} 문서(닉네임)를 다룬다. uid는 매번 FirebaseAuth의 현재 로그인
/// 유저에서 가져오므로, 반드시 AuthService.ensureSignedIn() 이후에 써야 한다.
class UserService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<bool> hasNickname() async {
    final doc = await _collection.doc(_uid).get();
    final nickname = doc.data()?['nickname'] as String?;
    return nickname != null && nickname.isNotEmpty;
  }

  // 최초 닉네임 설정에서만 호출한다. 닉네임을 나중에 바꿀 때는 createdAt을
  // 다시 덮어쓰지 않도록 updateNickname을 대신 쓴다.
  Future<void> saveNickname(String nickname) {
    return _collection.doc(_uid).set({
      'nickname': nickname,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 내 정보 화면에서 닉네임을 수정할 때 쓴다. createdAt은 건드리지 않는다.
  Future<void> updateNickname(String nickname) {
    return _collection.doc(_uid).set({
      'nickname': nickname,
    }, SetOptions(merge: true));
  }

  /// 여러 uid의 닉네임을 한 번에 조회한다. 그룹 멤버 목록 표시용.
  /// whereIn은 최대 30개까지만 되는데, 지금 규모(연구실 그룹)에서는 충분하다.
  Future<Map<String, String>> getNicknames(List<String> uids) async {
    if (uids.isEmpty) return {};
    final snap = await _collection
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return {
      for (final doc in snap.docs)
        doc.id: (doc.data()['nickname'] as String?) ?? '(이름 없음)',
    };
  }
}
