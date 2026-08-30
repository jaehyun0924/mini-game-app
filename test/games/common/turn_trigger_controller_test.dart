import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_app/games/common/turn_trigger_controller.dart';

void main() {
  group('TurnTriggerController', () {
    test('시작 시 첫 번째 참가자의 차례다', () {
      final controller = TurnTriggerController(
        participants: ['A', 'B', 'C'],
        triggerIndex: 2,
      );
      expect(controller.currentParticipant, 'A');
      expect(controller.triggered, isFalse);
      expect(controller.pressedIndices, isEmpty);
    });

    test('트리거가 아닌 슬롯을 누르면 다음 참가자로 턴이 넘어가고 false를 반환한다', () {
      final controller = TurnTriggerController(
        participants: ['A', 'B', 'C'],
        triggerIndex: 5,
      );

      final result = controller.press(0);

      expect(result, isFalse);
      expect(controller.triggered, isFalse);
      expect(controller.pressedIndices, {0});
      expect(controller.currentParticipant, 'B');
    });

    test('트리거 슬롯을 누르면 true를 반환하고 턴을 넘기지 않는다', () {
      final controller = TurnTriggerController(
        participants: ['A', 'B', 'C'],
        triggerIndex: 1,
      );
      controller.press(0); // A가 꽝을 누름 → B 차례로

      final result = controller.press(1); // B가 트리거를 누름

      expect(result, isTrue);
      expect(controller.triggered, isTrue);
      expect(controller.pressedIndices, {0, 1});
      // 트리거를 누른 B가 계속 "현재 참가자"로 남아야 결과 화면에서
      // "누가 뽑혔는지"를 currentParticipant로 그대로 보여줄 수 있다.
      expect(controller.currentParticipant, 'B');
    });

    test('참가자 수보다 많이 눌러도 턴이 순환한다', () {
      final controller = TurnTriggerController(
        participants: ['A', 'B'],
        triggerIndex: 99,
      );

      controller.press(0);
      expect(controller.currentParticipant, 'B');
      controller.press(1);
      expect(controller.currentParticipant, 'A');
      controller.press(2);
      expect(controller.currentParticipant, 'B');
    });

    test('여러 번 눌러도 눌린 슬롯이 모두 누적된다', () {
      final controller = TurnTriggerController(
        participants: ['A', 'B', 'C'],
        triggerIndex: 10,
      );

      controller.press(3);
      controller.press(4);
      controller.press(5);

      expect(controller.pressedIndices, {3, 4, 5});
      expect(controller.triggered, isFalse);
    });
  });
}
