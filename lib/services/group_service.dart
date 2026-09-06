import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_game_app/models/group.dart';

/// 그룹 생성/초대 코드로 참여를 다룬다. 그룹 문서와 초대 코드 문서는 순서대로
/// 만든다(자세한 이유는 docs/firestore-data-model.md 참고) — 그룹을 먼저 만들고
/// 그 그룹이 실제로 존재하는 상태에서 초대 코드를 잇따라 만든다. WriteBatch로
/// 한 번에 묶으면 더 안전해 보이지만, 보안 규칙이 "같은 batch 안에서 막 만들어진
/// 그룹"을 get()으로 확인할 때 그 그룹을 아직 없는 것으로 평가해서(batch 안의
/// 쓰기끼리는 서로 안 보임) 오히려 거부된다.
class GroupService {
  // 코드를 소리 내어 불러줄 때 헷갈리는 0/O, 1/I는 문자셋에서 뺐다.
  static const String _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int _codeLength = 6;
  static const int _maxCodeAttempts = 5;

  final CollectionReference<Map<String, dynamic>> _groups = FirebaseFirestore
      .instance
      .collection('groups');
  final CollectionReference<Map<String, dynamic>> _inviteCodes =
      FirebaseFirestore.instance.collection('inviteCodes');
  final Random _random = Random.secure();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  String _generateCode() {
    return List.generate(
      _codeLength,
      (_) => _codeChars[_random.nextInt(_codeChars.length)],
    ).join();
  }

  Future<GroupModel> createGroup(String name) async {
    for (var attempt = 0; attempt < _maxCodeAttempts; attempt++) {
      final code = _generateCode();
      final existing = await _inviteCodes.doc(code).get();
      if (existing.exists) continue;

      final groupRef = _groups.doc();
      await groupRef.set({
        'name': name,
        'inviteCode': code,
        'ownerId': _uid,
        'memberIds': [_uid],
        'createdAt': FieldValue.serverTimestamp(),
      });
      // 아주 드물게 이 두 번째 쓰기만 실패하면 초대 코드 없는 그룹이 남을 수
      // 있는데, 연구실 내기용 앱 규모에서는 감수할 만한 리스크라 재시도/롤백
      // 로직은 넣지 않는다.
      await _inviteCodes.doc(code).set({'groupId': groupRef.id});

      return GroupModel(
        id: groupRef.id,
        name: name,
        inviteCode: code,
        ownerId: _uid,
        memberIds: [_uid],
      );
    }
    throw Exception('초대 코드 생성에 실패했어요. 다시 시도해주세요');
  }

  /// 내가 속한 그룹 목록. 홈 화면 그룹 리스트가 이 스트림을 구독한다.
  Stream<List<GroupModel>> streamMyGroups() {
    return _groups.where('memberIds', arrayContains: _uid).snapshots().map(
      (snap) => snap.docs.map(GroupModel.fromSnapshot).toList(),
    );
  }

  Stream<GroupModel> streamGroup(String groupId) {
    return _groups
        .doc(groupId)
        .snapshots()
        .map((doc) => GroupModel.fromSnapshot(doc));
  }

  /// 코드로 그룹에 참여한다. 존재하지 않는 코드/그룹, 이미 가입된 그룹이면
  /// [GroupJoinException]을 던진다.
  Future<GroupModel> joinByCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    final codeDoc = await _inviteCodes.doc(normalizedCode).get();
    if (!codeDoc.exists) {
      throw GroupJoinException('존재하지 않는 코드예요');
    }

    final groupId = codeDoc.data()!['groupId'] as String;
    final groupRef = _groups.doc(groupId);
    final groupDoc = await groupRef.get();
    if (!groupDoc.exists) {
      throw GroupJoinException('존재하지 않는 그룹이에요');
    }

    final group = GroupModel.fromSnapshot(groupDoc);
    if (group.memberIds.contains(_uid)) {
      throw GroupJoinException('이미 가입된 그룹이에요');
    }

    await groupRef.update({
      'memberIds': FieldValue.arrayUnion([_uid]),
    });

    return GroupModel(
      id: group.id,
      name: group.name,
      inviteCode: group.inviteCode,
      ownerId: group.ownerId,
      memberIds: [...group.memberIds, _uid],
    );
  }

  /// 그룹 탈퇴. 방장은 탈퇴할 수 없다(보안 규칙 isLeavingSelf가 서버에서도
  /// 막는다) — 방장은 [deleteGroup]으로 그룹 자체를 지워야 한다.
  Future<void> leaveGroup(String groupId) {
    return _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([_uid]),
    });
  }

  /// 그룹 삭제(방장 전용, 보안 규칙에서도 방장인지 확인한다). sessions
  /// 하위 컬렉션과 inviteCodes 문서는 그대로 남지만, 그룹 문서가 사라지면
  /// 보안 규칙이 막아서 아무도 접근할 수 없는 고아 데이터가 된다 — 자세한
  /// 이유는 docs/firestore-data-model.md 참고.
  Future<void> deleteGroup(String groupId) {
    return _groups.doc(groupId).delete();
  }

  /// 초대 코드 재발급(방장 전용). 기존 코드를 지워 더 이상 그 코드로 들어올
  /// 수 없게 만들고, 새 코드를 그룹 문서와 inviteCodes 컬렉션에 반영한다.
  /// 두 쓰기 다 규칙 조건이 "이미 존재하는 그룹 문서"만 참조하고 서로의
  /// 결과를 참조하지 않으므로(그룹 생성 때와 달리 그룹 문서 자체가 새로
  /// 생기는 게 아니라 이미 있음), WriteBatch로 묶어도 안전하다.
  Future<String> reissueInviteCode(GroupModel group) async {
    for (var attempt = 0; attempt < _maxCodeAttempts; attempt++) {
      final newCode = _generateCode();
      final existing = await _inviteCodes.doc(newCode).get();
      if (existing.exists) continue;

      final batch = FirebaseFirestore.instance.batch();
      batch.delete(_inviteCodes.doc(group.inviteCode));
      batch.update(_groups.doc(group.id), {'inviteCode': newCode});
      batch.set(_inviteCodes.doc(newCode), {'groupId': group.id});
      await batch.commit();

      return newCode;
    }
    throw Exception('초대 코드 재발급에 실패했어요. 다시 시도해주세요');
  }
}

class GroupJoinException implements Exception {
  final String message;
  GroupJoinException(this.message);
}
