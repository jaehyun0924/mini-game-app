import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/text_styles.dart';

/// 이름/라벨을 가로로 나열해서 보여주는 행. selectedIndex/onSelect를 주면
/// 탭해서 선택할 수 있는 목록으로, 안 주면 정적인 라벨 목록으로 쓸 수 있다.
class LabelRow extends StatelessWidget {
  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  const LabelRow({
    super.key,
    required this.labels,
    this.selectedIndex,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              child: Text(
                labels[i],
                style: i == selectedIndex
                    ? kTextBody1.copyWith(
                        color: kColorPrimary,
                        fontWeight: FontWeight.w700,
                      )
                    : kTextBody1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
