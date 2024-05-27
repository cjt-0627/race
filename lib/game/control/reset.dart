import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ResetButton extends SpriteButtonComponent {
  bool click = false;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(50);
    anchor = Anchor.center;
    button = await Sprite.load('restart_100.png', srcPosition: Vector2(0, 5));
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withAlpha(100);
    canvas.drawCircle(const Offset(25, 25), 30, paint);
    super.render(canvas);
  }
}
