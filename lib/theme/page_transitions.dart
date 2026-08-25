import 'package:flutter/material.dart';

import 'motion.dart';

/// 화면 전환 느낌을 앱 전체에서 통일하기 위한 공용 PageRoute.
/// 오른쪽에서 살짝 슬라이드되며 페이드 인되는 형태로, 화면 이동할 때
/// MaterialPageRoute 대신 이걸 쓴다.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: kSlowDuration,
        reverseTransitionDuration: kSlowDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: kStandardCurve,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
