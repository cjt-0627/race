import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:jumpjump/game/background.dart';
import 'package:jumpjump/game/car.dart';

// class Line2 extends BodyComponent{
//   late ShapeHitbox hitbox;
//   int step;
//   Line2(this.step);
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

class Line extends BodyComponent with ContactCallbacks {
  final Vector2 position1, position2;
  final Background background;
  int step;
  final RouterComponent router;
  double num = 4.3;
  Line(
      {required this.position1,
      required this.position2,
      required this.background,
      required this.step,
      required this.router});
  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set((position1 - background.sprite.srcSize / 2) * 4 / num,
          (position2 - background.sprite.srcSize / 2) * 4 / num);
    final fixtureDef = FixtureDef(shape, friction: .4, isSensor: true);

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
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Car && (other.step - step).abs() <= 1) {
      other.step = step;
      if (step == 2) {
        other.timer.pause();
        router.pushNamed('game-over');
      }
    }
  }
}
