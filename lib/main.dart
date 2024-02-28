import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:flame/flame.dart';
import 'package:jumpjump/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  runApp(GameWidget(
    game: MyGame(),
    mouseCursor: SystemMouseCursors.move, //
  ));
}

class MyGame extends FlameGame with HasCollisionDetection {
  late RouterComponent router;
  late RedCar redCar ; //
  late SpriteComponent background;
  late SteeringWheel steeringWheel;
  late DRControl drControl;
  bool init = false;

  final timer = Timer(double.infinity, autoStart: false);
  final countdown = Timer(3, autoStart: false);

  Vector2? stapos, curpos; //
  List<WallPos> walls = [];
  List<Vector2> lines = [
    Vector2(877, 691) * 4,
    Vector2(774, 771) * 4,
    Vector2(549, 627) * 4
  ];
  @override
  void onGameResize(Vector2 size) {
    if (init) {
      steeringWheel.position = Vector2(size.x - steeringWheel.size.x / 2 - 50,
          size.y - steeringWheel.size.y / 2 - 40);
      drControl.position = Vector2(
        drControl.size.x / 2 + 50,
        size.y - drControl.size.y / 2 - 40,
      );
    }
    super.onGameResize(size);
  }

  @override
  Future<FutureOr<void>> onLoad() async {
    //FutureOr
    router = RouterComponent(
      routes: {
        'game-over': OverlayRoute(
          (context, game) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color:Colors.grey.withAlpha(200),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Time: ${timer.current.round()}',
                      style: const TextStyle(
                          fontSize: 40,
                          fontFamily: 'Micro5'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: 50,
                          width: 200,
                          child: ElevatedButton(
                              onPressed: () {
                                startGame();
                                router.pop();
                              },
                              child: const Text('Play',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily:
                                          'Micro5')))),
                    )
                  ],
                ),
              ],
            );
          },
        ), 
        'start': OverlayRoute((context, game) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.grey.withAlpha(200),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to My Race Game',
                    style: TextStyle(
                        fontSize: 40, fontFamily: 'Micro5'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                            onPressed: () {
                              startGame();
                              router.pop();
                            },
                            child: const Text('Play',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily:
                                        'Micro5')))),
                  )
                ],
              ),
            ],
          );
        }),
        'init': Route(() => PositionComponent()),
      },
      initialRoute: 'init',
    );

    Sprite backgroundSprite = Sprite(await images.load('map.png'));
    background = SpriteComponent()
      ..sprite = backgroundSprite
      ..size = backgroundSprite.originalSize * 4;
    world.add(background);

    redCar = RedCar(router: router, timer: timer);
    redCar.anchor = Anchor.center;
    redCar.position = Vector2(542, 584) * 4;
    redCar.size = Vector2(45, 63) / 1.2;
    redCar.sprite = Sprite(await images.load('/RedCar.png'));
    redCar.debugMode = false;
    redCar.debugColor = const Color.fromARGB(196, 0, 119, 255);
    world.add(redCar);
//
    for (var map in data) {
      //map
      walls.add(WallPos(
          4 * map['x1']!, 4 * map['y1']!, 4 * map['w']!, 4 * map['h']!));
    }
    for (int i = 0; i < walls.length; i++) {
      Wall wall = Wall()
        ..position = Vector2(walls[i].x, walls[i].y)
        ..size = Vector2(walls[i].width, walls[i].height);
      world.add(wall);
    }
    for (int i = 0; i < lines.length; i++) {
      Line line = Line(i + 1)
        ..position = lines[i]
        ..size = Vector2(6, 42) * 4;
      world.add(line);
    }

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = background.size / 2;
    redCar.position.addListener(() {
      camera.viewfinder.angle = redCar.angle;
    });

    steeringWheel = SteeringWheel(redCar);
    steeringWheel.position = Vector2(size.x - steeringWheel.size.x / 2 - 50,
        size.y - steeringWheel.size.y / 2 - 40);
    steeringWheel.steeringWheelIcon.sprite =
        Sprite(await images.load('SteeringWheel.png'));
    steeringWheel.debugMode = false;

    drControl = DRControl(redCar);
    drControl.position = Vector2(
      drControl.size.x / 2 + 50,
      size.y - drControl.size.y / 2 - 40,
    );
    drControl.debugMode = false;
    camera.viewfinder.zoom = 0.1;
    add(router);
  }

  @override
  void update(double dt) {
    timer.update(dt);
    countdown.update(dt);
    if (!init) {
      camera.viewfinder.zoom += dt * 0.3;
      camera.viewfinder.angle -= pi / 6 * dt;
      camera.viewfinder.position +=
          (redCar.position - background.size / 2) / 3 * dt;
      if (camera.viewfinder.zoom >= 1) {
        router.pushNamed('start');
        camera.viewfinder.zoom = 1;
        camera.follow(redCar);
        camera.viewport.add(steeringWheel);
        camera.viewport.add(drControl);
        init = true;
      }
    }
    super.update(dt);
  }

  void startGame() {
    redCar.position = Vector2(542, 584) * 4;
    redCar.angle = camera.viewfinder.angle = pi / 2;
    redCar.dir = 0;
    countdown.onTick = () {
      timer.reset();
      timer.start();
    };
    countdown.reset();
    countdown.start();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final TextPaint textPaintA = TextPaint(
      style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'Micro5'),
    );
    textPaintA.render(canvas, 'By CJT & YCY', Vector2(size.x - 30, 10),
        anchor: Anchor.topRight);
    if (init) {
      final TextPaint textPaintSpeed = TextPaint(
        style: const TextStyle(
            color: Colors.white,
            fontSize: 70,
            fontFamily: 'Micro5'),
      );
      textPaintSpeed.render(canvas, "${(redCar.v / 4).round().abs()}",
          Vector2(size.x / 2, size.y),
          anchor: Anchor.bottomCenter);
      if (timer.isRunning()) {
        final TextPaint textPaint = TextPaint(
          style: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontFamily: 'Micro5'),
        );
        textPaint.render(
          canvas,
          "Time: ${timer.current.round()}",
          Vector2(30,10 ),
        );
      }
      if (countdown.isRunning()) {
        final Paint paint = Paint()
          ..color = Colors.grey.withAlpha(200)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(size.x, size.y) / 2,
            -6400 *
                    pow((countdown.current - countdown.current.floor()) - 0.5,
                        6) +
                100,
            paint);
        final TextPaint textPaintCountdown = TextPaint(
          style: TextStyle(
              color: Colors.white,
              fontSize: -102400 *
                      pow((countdown.current - countdown.current.floor()) - 0.5,
                          10) +
                  100,
              fontFamily: 'Micro5'),
        );
        textPaintCountdown.render(
          canvas,
          '${3 - countdown.current.floor()}',
          size / 2,
          anchor: Anchor.center,
        );
      }
    }
  }
}

class SteeringWheelIcon extends SpriteComponent {
  SteeringWheelIcon() : super(size: Vector2(180, 180), anchor: Anchor.center);
  double dir = 0;
}

class SteeringWheel extends PositionComponent with DragCallbacks {
  double dir = 0;
  RedCar redCar;
  SteeringWheelIcon steeringWheelIcon = SteeringWheelIcon();
  SteeringWheel(this.redCar)
      : super(size: (Vector2(180, 180)), anchor: Anchor.center);

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
      : super(size: (Vector2(65, 170)), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 219, 158, 130)
      ..style = PaintingStyle.fill;
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * 1.2;
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
        size.x / 2 - 6 * 1.2,
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
  RouterComponent router;
  Timer timer;
  int step = 0;
  RedCar({required this.router, required this.timer}) : super(angle: pi / 2);

  late ShapeHitbox hitbox;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall && history.isNotEmpty) {
      v = a = 0;
      frozen = true;
    } else if (other is Line && (other.step - step).abs() == 1) {
      step = other.step;
      if (step == 3) {
        timer.pause();
        router.pushNamed('game-over');
      }
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
      Vector2(15, 3) / 1.2,
      Vector2(3, 18) / 1.2,
      Vector2(3, 51) / 1.2,
      Vector2(15, 63) / 1.2,
      Vector2(33, 63) / 1.2,
      Vector2(45, 51) / 1.2,
      Vector2(45, 18) / 1.2,
      Vector2(33, 3) / 1.2
    ])
      ..paint = paint
      ..renderShape = false;
    add(hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!frozen) {
      if (timer.isRunning()) {
        if (run > 0) {
          a = 290 * run;
        } else if (run < 0) {
          a = 260 * run;
        } else {
          a = 0;
        }
      }
      if (v != 0) {
        if (run == 0 && v < 1) {
          a = v = 0;
        } else {
          a += (v > 0 ? -200 : 200);
        }
      }
      v += a * dt;
      position += Vector2(v * cos(dir), v * -sin(dir)) * dt;
      if (v != 0) {
        dir += v * dt * -turn / size.y * pi / 4;
        angle = -dir + pi / 2;
      }
      if (history.isEmpty || position != history.last) {
        history.add(position.clone());
      }
    } else {
      history.removeLast();
      position = history.last;
    }
    super.update(dt);
  }
}
