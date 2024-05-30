import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:flame/flame.dart';
import 'package:drag_racing/game/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drag_racing/key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  await Supabase.initialize(
    url: 'https://mjfmosfdhouzlcxgupts.supabase.co',
    anonKey: anonkey,
  );
  runApp(GameWidget(
    game: MyGame(),
    mouseCursor: SystemMouseCursors.move,
  ));
}

final supabase = Supabase.instance.client;
