import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:forge2d/src/dynamics/body.dart';
import 'package:jumpjump/game/background.dart';

// class Wall2 extends PositionComponent {
//   late ShapeHitbox hitbox;
//   @override
//   FutureOr<void> onLoad() {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//     hitbox = RectangleHitbox(collisionType: CollisionType.passive)
//       ..paint = paint
//       ..renderShape = false;
//     add(hitbox);
//     return super.onLoad();
//   }
// }

class WallPos {
  double x, y, w, h;
  WallPos(this.x, this.y, this.w, this.h);
  double get x2 => x + w;
  double get y2 => y + h;
}

class Wall extends BodyComponent {
  final Vector2 position1, position2;
  final Background background;
  double num=4.3;
  Wall(
      {required this.position1,
      required this.position2,
      required this.background});
  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set((position1 - background.sprite.srcSize/2) * 4 / num,
          (position2 - background.sprite.srcSize/2) * 4 / num);
    final fixtureDef = FixtureDef(shape, friction: .4);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());
    paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() {
    renderBody = false;
    return super.onLoad();
  }
}
