import 'package:flutter/material.dart';
import 'package:mini_game_app/models/session_result.dart';

/// 결과 화면들이 게임이 끝났을 때 공용으로 호출하는 헬퍼.
/// onResult가 null이면(그룹 없이 게임을 시작한 경우) 아무 것도 하지 않는다.
/// 저장에 실패해도 복잡한 오프라인 큐를 만들지 않고, 토스트 + 재시도 버튼만
/// 보여준다 — Firestore 자체 오프라인 캐시가 일시적인 네트워크 끊김은 어느
/// 정도 커버해준다.
void recordGameResult(
  BuildContext context,
  GameResultCallback? onResult,
  SessionResult result,
) {
  if (onResult == null) return;

  onResult(result).catchError((_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('기록 저장에 실패했어요'),
        action: SnackBarAction(
          label: '재시도',
          onPressed: () => recordGameResult(context, onResult, result),
        ),
      ),
    );
  });
}
