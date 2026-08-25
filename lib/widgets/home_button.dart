import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';

import 'shrink_button.dart';

/// 결과 화면 AppBar에 넣는 공용 홈 버튼. 참가자 입력→설정→결과처럼 여러
/// 화면을 거쳐 쌓인 스택을 한 번에 걷어내고 첫 화면(게임 선택 홈)으로 바로
/// 돌아간다 — 뒤로가기를 여러 번 눌러 설정 화면들을 하나씩 되짚어갈 필요가 없다.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShrinkButton(
      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.home_outlined, color: kColorPrimary),
      ),
    );
  }
}
