import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart'hide Timer; 
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:jumpjump/data.dart';
import 'package:jumpjump/game/background.dart';
import 'package:jumpjump/game/collision/line.dart';
import 'package:jumpjump/game/collision/wall.dart';
import 'package:jumpjump/game/control/drcontrol.dart';
import 'package:jumpjump/game/control/steering_wheel.dart';
import 'package:jumpjump/game/red_car.dart';

class MyGame extends Forge2DGame {
  MyGame() : super(gravity: Vector2(0, 0));
  late RouterComponent router;
  late RedCar redCar; 
  late Background background;
  late SteeringWheel steeringWheel;
  late DRControl drControl;
  bool init = false;

  final timer = Timer(double.infinity, autoStart: false);
  final countdown = Timer(3, autoStart: false);

  Vector2? stapos, curpos; 
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
  Future<void> onLoad() async {
    await super.onLoad();
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

    background=Background(sprite:await loadSprite('mymap.png'));
    await world.add(background);
    
    redCar = RedCar(router: router, timer: timer,position: Vector2(200,200),sprite:await loadSprite('RedCar.png') );

    redCar.debugMode = false;
    redCar.debugColor = const Color.fromARGB(196, 0, 119, 255);
    await world.add(redCar);
//
    for (var map in data) {
      //map
      walls.add(WallPos(
           map['x1']!,  map['y1']!,  map['w']!, map['h']!));
    }
    for (int i = 0; i < walls.length; i++) {
      Wall wall = Wall(position1:Vector2(walls[i].x, walls[i].y),position2:Vector2(walls[i].x2, walls[i].y2),background: background);
      world.add(wall);
    }
    for (int i = 0; i < lines.length; i++) {
      Line line = Line(i + 1)
        ..position = lines[i]
        ..size = Vector2(6, 42) * 4;
      world.add(line);
    }

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();


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
      // camera.viewfinder.position +=
      //     (redCar.position - background.size / 2) / 3 * dt;
      if (camera.viewfinder.zoom >= 1) {
        router.pushNamed('start');
        print(redCar.hashCode);
        camera.viewfinder.zoom = 1;
        camera.follow(redCar);
        camera.viewport.add(steeringWheel);
        camera.viewport.add(drControl);
        init = true;
      }
      
    }
    else{
      camera.moveTo(redCar.body.position);
    }
    super.update(dt);
  }

  void startGame() {

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
      textPaintSpeed.render(canvas, "${(0/ 4).round().abs()}",
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