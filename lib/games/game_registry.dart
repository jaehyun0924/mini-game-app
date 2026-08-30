import 'crocodile_teeth/crocodile_teeth_mini_game.dart';
import 'ladder/ladder_mini_game.dart';
import 'lotto_draw/lotto_mini_game.dart';
import 'mini_game.dart';
import 'popup_pirate/popup_pirate_mini_game.dart';
import 'roulette/roulette_mini_game.dart';
import 'straw_draw/straw_draw_mini_game.dart';

/// 앱에서 제공하는 모든 게임 목록. 새 게임을 추가하려면 MiniGame을 구현한
/// 클래스를 만들고 여기 등록하기만 하면 된다.
final List<MiniGame> kAllGames = [
  LadderMiniGame(),
  RouletteMiniGame(),
  StrawDrawMiniGame(),
  LottoDrawMiniGame(),
  PopupPirateMiniGame(),
  CrocodileTeethMiniGame(),
];
