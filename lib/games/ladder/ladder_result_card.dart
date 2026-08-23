import 'package:flutter/material.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/motion.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';

import 'confetti_burst.dart';
import 'ladder_outcome.dart';

/// 참가자가 도착한 지점에 결과를 튕기듯 보여주는 카드.
/// 특별 결과는 색종이 효과 + 색이 있는 카드로, 나머지는 담백한 흰 카드로 보여준다.
class LadderResultCard extends StatelessWidget {
  final LadderOutcome outcome;

  const LadderResultCard({super.key, required this.outcome});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: kDefaultDuration,
      curve: kBounceCurve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (outcome.isSpecial) const ConfettiBurst(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMd,
              vertical: kSpacingSm,
            ),
            decoration: BoxDecoration(
              color: outcome.isSpecial ? kColorPrimary : kColorSurface,
              borderRadius: BorderRadius.circular(kRadiusLg),
              border: outcome.isSpecial
                  ? null
                  : Border.all(color: kColorBorder),
              boxShadow: outcome.isSpecial
                  ? [
                      BoxShadow(
                        color: kColorPrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              outcome.label,
              style: kTextTitle.copyWith(
                color: outcome.isSpecial ? Colors.white : kColorTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
