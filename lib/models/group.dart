import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final List<String> memberIds;

  const GroupModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.memberIds,
  });

  factory GroupModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GroupModel(
      id: doc.id,
      name: data['name'] as String,
      inviteCode: data['inviteCode'] as String,
      ownerId: data['ownerId'] as String,
      memberIds: List<String>.from(data['memberIds'] as List),
    );
  }
}
