import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/experimental.dart';
import 'package:jumpjump/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setPortrait();
  await Flame.device.fullScreen();
  runApp(GameWidget(
    game: MyGame(),
    mouseCursor: SystemMouseCursors.move,
  ));
}

class MyGame extends FlameGame with HasCollisionDetection {
  late RedCar redCar;
  late Runbutton runbutton;
  late SpriteComponent background;
  late BackSlidebutton backSlidebutton;
  late SteeringWheel steeringWheel;
  // late ControlBoard controlBoard;
  Vector2? stapos, curpos;
  final cameraSize = Vector2(300, 533);
  List<WallPos> walls = [];

  @override
  Future<FutureOr<void>> onLoad() async {
    Sprite backgroundSprite = Sprite(await images.load('mymap.png'));
    background = SpriteComponent()
      ..sprite = backgroundSprite
      ..size = backgroundSprite.originalSize * 3;
    world.add(background);

    redCar = RedCar();
    redCar.anchor = Anchor.center;
    redCar.position = Vector2(200, 620);
    redCar.size = Vector2(45, 63);
    redCar.sprite = Sprite(await images.load('/RedCar.png'));
    redCar.debugMode = true;
    redCar.debugColor = const Color.fromARGB(196, 0, 119, 255);
    world.add(redCar);

    // controlBoard = ControlBoard();
    for (var map in data) {
      walls.add(WallPos(
          3 * map['x1']!, 3 * map['y1']!, 3 * map['w']!, 3 * map['h']!));
    }
    for (int i = 0; i < walls.length; i++) {
      Wall wall = Wall()
        ..position = Vector2(walls[i].x, walls[i].y)
        ..size = Vector2(walls[i].width, walls[i].height);
      world.add(wall);
    }
    camera = CameraComponent.withFixedResolution(
        width: cameraSize.x, height: cameraSize.y);
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(redCar);
    camera.setBounds(
        Rectangle.fromLTRB(
            cameraSize.x / 2,
            cameraSize.y / 2,
            background.size.x - cameraSize.x / 2,
            background.size.y - cameraSize.y / 2),
        considerViewport: true);
    // camera.viewport.add(controlBoard);
    runbutton = Runbutton(redCar);
    runbutton.position = Vector2(
        runbutton.size.x * 2 + 10, cameraSize.y - runbutton.size.y / 2 - 10);
    runbutton.button = SpriteComponent()
      ..sprite = Sprite(await images.load('runbutton.png'))
      ..size = runbutton.size;
    runbutton.buttonDown = SpriteComponent()
      ..sprite = Sprite(await images.load('runbuttondown.png'))
      ..size = runbutton.size;
    camera.viewport.add(runbutton);

    backSlidebutton = BackSlidebutton(redCar);
    backSlidebutton.position = Vector2(backSlidebutton.size.x / 2 + 10,
        cameraSize.y - backSlidebutton.size.y / 2 - 10);
    backSlidebutton.button = SpriteComponent()
      ..sprite = Sprite(await images.load('backslidebutton.png'))
      ..size = backSlidebutton.size;
    backSlidebutton.buttonDown = SpriteComponent()
      ..sprite = Sprite(await images.load('backslidebuttondown.png'))
      ..size = backSlidebutton.size;
    camera.viewport.add(backSlidebutton);

    steeringWheel = SteeringWheel(redCar);
    steeringWheel.position = Vector2(
        cameraSize.x - steeringWheel.size.x / 2 - 10,
        cameraSize.y - steeringWheel.size.y / 2 - 10);
    camera.viewport.add(steeringWheel);
  }
}

class SteeringWheel extends PositionComponent with DragCallbacks {
  double dir = 0;
  RedCar redCar;
  SteeringWheel(this.redCar)
      : super(size: (Vector2(100, 50)), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 219, 158, 130)
      ..style = PaintingStyle.fill;
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2)),
        paint);
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2)),
        borderPaint);
    Paint cpaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset((size.x - size.y) * (dir + 1) / 2 + size.y / 2, size.y / 2),
        size.y / 2 - 6,
        cpaint);
    super.render(canvas);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dir = (event.localEndPosition.x * 2 - size.y) / (size.x - size.y) - 1;
    if (dir > 1) dir = 1;
    if (dir < -1) dir = -1;
    redCar.turn=dir;
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    dir = 0;
    redCar.turn=0;
    super.onDragEnd(event);
  }
}

// class ControlBoard extends PositionComponent {
//   Vector2? start, current;
//   ControlBoard({this.start, this.current}) : super(priority: 1);
//   @override
//   void render(Canvas canvas) {
//     Paint paint = Paint()
//       ..color = const Color.fromARGB(255, 219, 158, 130)
//       ..style = PaintingStyle.fill;
//     Paint borderPaint = Paint()
//       ..color = const Color.fromARGB(255, 0, 0, 0)
//       ..strokeWidth = 12
//       ..style = PaintingStyle.stroke;
//     Paint littlePaint = Paint()
//       ..color = const Color.fromARGB(255, 0, 0, 0)
//       ..style = PaintingStyle.fill;
//     if (start != null && current != null) {
//       const br = 28, sr = 14;
//       canvas.drawCircle(Offset(start!.x, start!.y), br.toDouble(), paint);
//       canvas.drawCircle(
//           Offset(start!.x, start!.y), br.toDouble() + 5, borderPaint);
//       double r =
//           sqrt(pow(current!.x - start!.x, 2) + pow(current!.y - start!.y, 2));
//       double x, y;
//       if (r > (br - sr)) {
//         y = (current!.y - start!.y) * ((br - sr) / r) + start!.y;
//         x = (current!.x - start!.x) * ((br - sr) / r) + start!.x;
//       } else {
//         x = current!.x;
//         y = current!.y;
//       }
//       canvas.drawCircle(Offset(x, y), sr.toDouble(), littlePaint);
//     }
//     super.render(canvas);
//     super.render(canvas);
//   }
// }
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
      ..renderShape = true;
    add(hitbox);
    return super.onLoad();
  }
}

class Runbutton extends ButtonComponent {
  RedCar redCar;
  Runbutton(this.redCar)
      : super(
            anchor: Anchor.center,
            size: Vector2(50, 50),
            onPressed: () => redCar.run = true,
            onReleased: () => redCar.run = false,
            onCancelled: () => redCar.run = false);
}

class BackSlidebutton extends ButtonComponent {
  RedCar redCar;
  BackSlidebutton(this.redCar)
      : super(
            anchor: Anchor.center,
            size: Vector2(50, 50),
            onPressed: () => redCar.back = true,
            onReleased: () => redCar.back = false,
            onCancelled: () => redCar.back = false);
}

class WallPos {
  double x, y, w, h;
  WallPos(this.x, this.y, this.w, this.h);
  double get width => w == 0 ? 3 : w;
  double get height => h == 0 ? 3 : h;
}

class RedCar extends SpriteComponent with CollisionCallbacks {
  double v = 0, a = 0;
  bool run = false, back = false;
  double dir = 0, turn = 0;
  
  RedCar():super(angle: pi/2);

  late ShapeHitbox hitbox;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print(other);
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    print("end");
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    hitbox = PolygonHitbox([
      Vector2(15, 3),
      Vector2(3, 18),
      Vector2(3, 51),
      Vector2(15, 63),
      Vector2(33, 63),
      Vector2(45, 51),
      Vector2(45, 18),
      Vector2(33, 3)
    ])
      ..paint = paint
      ..renderShape = false;
    add(hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (run && !back) {
      a = 320;
    } else if (back && !run) {
      a = -260;
    } else {
      a = 0;
    }
    if (v != 0) a += (v > 0 ? -230 : 230);
    v += a * dt;
    position += Vector2(v * cos(dir), v * -sin(dir)) * dt;
    if (v != 0) {
      dir += v * dt * -turn / size.y * pi / 4;
      angle = -dir+pi/2;
    }
    super.update(dt);
  }
}
