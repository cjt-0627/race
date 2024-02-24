import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flame/game.dart';
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
  late SpriteComponent background;
  late SteeringWheel steeringWheel;
  late DRControl drControl;

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
    redCar.position = Vector2(200,550);
    redCar.size = Vector2(45, 63) / 1.5;
    redCar.sprite = Sprite(await images.load('/RedCar.png'));
    redCar.debugMode = true;
    redCar.debugColor = const Color.fromARGB(196, 0, 119, 255);
    world.add(redCar);

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
    redCar.position.addListener(() {
      camera.viewfinder.angle = redCar.angle;
    });

    camera.setBounds(
        Rectangle.fromLTRB(
            cameraSize.x / 2,
            cameraSize.y / 2,
            background.size.x - cameraSize.x / 2,
            background.size.y - cameraSize.y / 2),
        considerViewport: true);

    steeringWheel = SteeringWheel(redCar);
    steeringWheel.position = Vector2(
        cameraSize.x - steeringWheel.size.x / 2 - 10,
        cameraSize.y - steeringWheel.size.y / 2 - 10);
    steeringWheel.steeringWheelIcon.sprite =
        Sprite(await images.load('SteeringWheel.png'));
    steeringWheel.debugMode = true;
    camera.viewport.add(steeringWheel);

    drControl = DRControl(redCar);
    drControl.position = Vector2(
      drControl.size.x + 10,
      cameraSize.y - drControl.size.y / 2 - 10,
    );
    drControl.debugMode = true;
    camera.viewport.add(drControl);
  }
}

class SteeringWheelIcon extends SpriteComponent {
  SteeringWheelIcon() : super(size: Vector2(100, 100), anchor: Anchor.center);
  double dir = 0;
}

class SteeringWheel extends PositionComponent with DragCallbacks {
  double dir = 0;
  RedCar redCar;
  SteeringWheelIcon steeringWheelIcon = SteeringWheelIcon();
  SteeringWheel(this.redCar)
      : super(size: (Vector2(100, 100)), anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    steeringWheelIcon.position = size / 2;
    add(steeringWheelIcon);
    return super.onLoad();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dir = event.localEndPosition.x / size.x * 2 - 1;
    if (dir > 1) dir = 1;
    if (dir < -1) dir = -1;
    steeringWheelIcon.angle = dir * pi / 2;
    redCar.turn = dir;
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    dir = 0;
    redCar.turn = 0;
    steeringWheelIcon.angle = 0;
    super.onDragEnd(event);
  }
}

class DRControl extends PositionComponent with DragCallbacks {
  double f = 0;
  RedCar redCar;
  DRControl(this.redCar)
      : super(size: (Vector2(50, 100)), anchor: Anchor.center);

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
        Offset(size.x / 2, (size.y - size.x) * (f + 1) / 2 + size.x / 2),
        size.x / 2 - 6,
        cpaint);
    super.render(canvas);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    f = (event.localEndPosition.y * 2 - size.x) / (size.y - size.x) - 1;
    if (f > 1) f = 1;
    if (f < -1) f = -1;
    redCar.run = -f;
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    f = 0;
    redCar.run = 0;
    super.onDragEnd(event);
  }
}

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

class RedCar extends SpriteComponent with CollisionCallbacks {
  double v = 0, a = 0;
  double dir = 0, turn = 0, run = 0;
  bool frozen = false;
  List<Vector2> history = [];

  RedCar() : super(angle: pi / 2);

  late ShapeHitbox hitbox;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall && history.isNotEmpty) {
      v = a = 0;
      frozen = true;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    frozen = false;
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    hitbox = PolygonHitbox([
      Vector2(15, 3) / 1.5,
      Vector2(3, 18) / 1.5,
      Vector2(3, 51) / 1.5,
      Vector2(15, 63) / 1.5,
      Vector2(33, 63) / 1.5,
      Vector2(45, 51) / 1.5,
      Vector2(45, 18) / 1.5,
      Vector2(33, 3) / 1.5
    ])
      ..paint = paint
      ..renderShape = false;
    add(hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!frozen) {
      if (run > 0) {
        a = 290 * run;
      } else if (run < 0) {
        a = 260 * run;
      } else {
        a = 0;
      }
      if (v != 0) {
        if (run == 0 && v < 1) {
          a = v = 0;
        } else {
          a += (v > 0 ? -230 : 230);
        }
      }
      v += a * dt;
      position += Vector2(v * cos(dir), v * -sin(dir)) * dt;
      if (v != 0) {
        dir += v * dt * -turn / size.y * pi / 4;
        angle = -dir + pi / 2;
      }
      if(history.isEmpty || position!=history.last)
      {
        history.add(position.clone());
      }
    }
    else
    {
      history.removeLast();
      position=history.last;
    }
    super.update(dt);
  }
}
