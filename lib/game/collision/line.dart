import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart' hide Route, OverlayRoute;

class Wall extends PositionComponent {
  late ShapeHitbox hitbox;
  @override
  FutureOr<void> onLoad() {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    hitbox = RectangleHitbox(collisionType: CollisionType.passive)
      ..paint = paint
      ..renderShape = false;
    add(hitbox);
    return super.onLoad();
  }
}

class WallPos {
  double x, y, w, h;
  WallPos(this.x, this.y, this.w, this.h);
  double get width => w == 0 ? 3 : w;
  double get height => h == 0 ? 3 : h;
}