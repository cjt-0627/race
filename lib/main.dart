import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:flame/flame.dart';
import 'package:drag_racing/game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  runApp(GameWidget(
    game: MyGame(),
    mouseCursor: SystemMouseCursors.move,
  ));
}
