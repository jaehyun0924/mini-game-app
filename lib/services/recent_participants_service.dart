import 'package:shared_preferences/shared_preferences.dart';

/// 최근에 게임에 참가시켰던 사람 이름을 기기(로컬)에 저장해뒀다가, 참가자
/// 입력 화면에서 다시 타이핑하지 않고 "불러오기"로 바로 추가할 수 있게 한다.
/// 실제로 같이 노는 사람은 그룹마다 다를 수 있어 그룹별로 따로 저장하고
/// (그룹 없이 홈 화면에서 바로 시작한 경우는 'global' 키를 쓴다), 여러 기기가
/// 공유할 필요는 없는 개인 편의 기능이라 Firestore가 아니라 로컬 저장소만 쓴다.
class RecentParticipantsService {
  static const int _maxEntries = 20;

  String _key(String? groupId) => 'recent_participants_${groupId ?? 'global'}';

  Future<List<String>> load(String? groupId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key(groupId)) ?? [];
  }

  /// 방금 플레이한 참가자들을 "최근" 목록 맨 앞으로 올린다. 중복은 제거하고,
  /// 최대 개수를 넘으면 오래된 이름부터 잘라낸다.
  Future<void> recordPlayed(String? groupId, List<String> participants) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(groupId);
    final existing = prefs.getStringList(key) ?? [];
    final merged = [
      ...participants,
      ...existing.where((name) => !participants.contains(name)),
    ];
    await prefs.setStringList(key, merged.take(_maxEntries).toList());
  }
}
