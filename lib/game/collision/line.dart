import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart' hide Route, OverlayRoute;

class Line extends PositionComponent {
  late ShapeHitbox hitbox;
  int step;
  Line(this.step);
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

