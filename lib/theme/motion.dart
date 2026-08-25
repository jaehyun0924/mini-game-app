import 'package:flutter/material.dart';

// 공용 애니메이션 duration/curve 상수. 게임마다 버튼 눌림, 화면 전환 느낌이
// 달라지지 않도록 여기서 관리해서 가져다 쓴다.

const Duration kPressDuration = Duration(milliseconds: 150); // 버튼 눌림 등 짧은 반응
const Duration kDefaultDuration = Duration(milliseconds: 300); // 일반적인 전환
const Duration kSlowDuration = Duration(milliseconds: 500); // 화면 전환 등 느린 애니메이션
const Duration kRevealDuration = Duration(
  milliseconds: 1400,
); // 사다리처럼 여러 요소가 순차적으로 등장하는 연출 전체 길이
const Duration kPathTraceDuration = Duration(
  milliseconds: 1200,
); // 경로를 따라 점(마커)이 이동하는 연출 전체 길이
const Duration kSpinDuration = Duration(
  milliseconds: 3200,
); // 룰렛처럼 여러 바퀴 돌다가 감속하며 멈추는 연출 전체 길이
const Duration kShuffleDuration = Duration(
  milliseconds: 1400,
); // 제비뽑기/로또뽑기처럼 카드가 여러 번 자리를 바꾸며 섞이는 연출 전체 길이

// 토스 특유의 탄성 있게 튀기는 느낌. Curves.easeOutBack은 목표값을 살짝
// 넘어섰다가 되돌아오는 형태라 그 느낌을 잘 표현해준다.
const Curve kBounceCurve = Curves.easeOutBack;
const Curve kStandardCurve = Curves.easeInOut;
// 회전각처럼 "물리적으로 되돌아가면 안 되는" 값에 쓰는 감속 커브.
// kBounceCurve(easeOutBack)는 목표를 넘었다가 되돌아오는 형태라, 회전각에
// 쓰면 바퀴가 순간적으로 역회전하는 것처럼 보인다 — 절대 섞어 쓰지 말 것.
const Curve kSpinCurve = Curves.easeOutQuint;
