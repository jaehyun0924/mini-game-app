import 'package:integration_test/integration_test_driver.dart';

/// animation_perf_test.dart를 `flutter drive`로 실행할 때 필요한 드라이버.
/// 테스트가 끝나면 traceAction 결과가 build/integration_response_data.json 으로 쓰인다.
Future<void> main() => integrationDriver();
