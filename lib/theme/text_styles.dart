import 'package:flutter/material.dart';

import 'colors.dart';

// 폰트 크기/굵기 스케일. 커스텀 폰트는 아직 도입하지 않고 시스템 기본 폰트를 쓴다.

const TextStyle kTextHeading1 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: kColorTextPrimary,
);

const TextStyle kTextHeading2 = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: kColorTextPrimary,
);

const TextStyle kTextTitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kColorTextPrimary,
);

const TextStyle kTextBody1 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kColorTextPrimary,
);

const TextStyle kTextBody2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kColorTextSecondary,
);

const TextStyle kTextCaption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kColorTextSecondary,
);
