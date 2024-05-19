import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flame/game.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:forge2d/src/dynamics/body.dart';
import 'package:jumpjump/game/collision/line.dart';
import 'package:jumpjump/game/collision/wall.dart';

// class RedCar2 extends SpriteComponent with CollisionCallbacks {
//   double v = 0, a = 0;
//   double dir = 0, turn = 0, run = 0;
//   bool frozen = false;
//   List<Vector2> history = [];
//   RouterComponent router;
//   Timer timer;
//   int step = 0;
//   RedCar2({required this.router, required this.timer}) : super(angle: pi / 2);

//   late ShapeHitbox hitbox;

//   @override
//   void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
//     if (other is Wall && history.isNotEmpty) {
//       v = a = 0;
//       frozen = true;
//     } else if (other is Line && (other.step - step).abs() == 1) {
//       step = other.step;
//       if (step == 3) {
//         timer.pause();
//         router.pushNamed('game-over');
//       }
//     }
//     super.onCollision(intersectionPoints, other);
//   }

//   @override
//   void onCollisionEnd(PositionComponent other) {
//     frozen = false;
//     super.onCollisionEnd(other);
//   }

//   @override
//   FutureOr<void> onLoad() {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 10
//       ..style = PaintingStyle.stroke;
//     hitbox = PolygonHitbox([
//       Vector2(15, 3) / 1.2,
//       Vector2(3, 18) / 1.2,
//       Vector2(3, 51) / 1.2,
//       Vector2(15, 63) / 1.2,
//       Vector2(33, 63) / 1.2,
//       Vector2(45, 51) / 1.2,
//       Vector2(45, 18) / 1.2,
//       Vector2(33, 3) / 1.2
//     ])
//       ..paint = paint
//       ..renderShape = false;
//     add(hitbox);
//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     if (!frozen) {
//       if (timer.isRunning()) {
//         if (run > 0) {
//           a = 290 * run;
//         } else if (run < 0) {
//           a = 260 * run;
//         } else {
//           a = 0;
//         }
//       }
//       if (v != 0) {
//         if (run == 0 && v.abs() < 1) {
//           a = v = 0;
//         } else {
//           a += (v > 0 ? -200 : 200);
//         }
//       }
//       v += a * dt;
//       position += Vector2(v * cos(dir), v * -sin(dir)) * dt;
//       if (v != 0) {
//         dir += v * dt * -turn / size.y * pi / 4;
//         angle = -dir + pi / 2;
//       }
//       if (history.isEmpty || position != history.last) {
//         history.add(position.clone());
//       }
//     } else {
//       history.removeLast();
//       position = history.last;
//     }
//     super.update(dt);
//   }
// }

class RedCar extends BodyComponent with HasGameRef<Forge2DGame> {
  RouterComponent router;
  Timer timer;
  final Vector2 position;
  final Sprite sprite;
  Vector2 impulseValue = Vector2.zero(), fc = Vector2.zero();
  RedCar(
      {required this.router,
      required this.timer,
      required this.position,
      required this.sprite});

  void run(double degree) {
    impulseValue =
        Vector2(10 * sin(body.angle), 10 * cos(body.angle)) * 10000 * degree;
  }

  void turn(double dir) {
    final k=8.0,v = body.linearVelocity;
    fc = Vector2(v.y, v.x) / sqrt(v.dot(v)) * dir * body.getMassData().mass/k;
    body.angularVelocity = sqrt(v.dot(v)) * dir/k * 0.1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    add(SpriteComponent(
        sprite: sprite, size: Vector2(35, 50), anchor: Anchor.center));
    print(hashCode);
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    final vertices = [
      Vector2(-8.75, 25),
      Vector2(-17.5, 12.5),
      Vector2(-17.5, -12.5),
      Vector2(-8.75, -25),
      Vector2(8.75, -25),
      Vector2(17.5, -12.5),
      Vector2(17.5, 12.5),
      Vector2(8.75, 25),
    ];
    shape.set(vertices);
    final fixtureDef = FixtureDef(
      shape,
      friction: 10,
      density: 100,
      restitution: 2,
    );
    final bodyDef = BodyDef(position: position, type: BodyType.dynamic);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    Vector2 v = body.linearVelocity;
    body.applyLinearImpulse(impulseValue);
    print(body.linearVelocity);
    if (v != Vector2.zero()) {
      body.applyLinearImpulse(-v / sqrt(v.dot(v)) * 1000);
      body.applyLinearImpulse(fc);
    }
    super.update(dt);
  }
}
