/// 그룹 랭킹/개인 통계 화면이 공용으로 쓰는 집계 결과 한 줄.
///
/// "승/패"는 세션에 기록된 결과의 isSpecial 여부로 정의한다 — 이 앱은
/// 내기용 미니게임 모음이라, "커피 사기"처럼 isSpecial=true로 표시되는
/// 결과를 받은 쪽을 "패"로, 나머지를 "승"으로 센다.
class RankingEntry {
  final String participant;
  final int playedCount;
  final int specialCount;
  final int winCount;

  RankingEntry({required this.participant, required this.playedCount, required this.specialCount})
    : winCount = playedCount - specialCount;
}
