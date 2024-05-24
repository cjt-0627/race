import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:jumpjump/game/tire.dart';

class Car extends BodyComponent {
  Car(this.sprite, this.startPosition)
      : super(
          priority: 3,
          paint: Paint()..color = Colors.transparent,
        );
  final Vector2 startPosition;
  final Sprite sprite;
  late final List<Tire> tires;
  final ValueNotifier<int> lapNotifier = ValueNotifier<int>(1);
  late final Image _image;
  final size = const Size(6, 10);
  final scale = 1.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & size;
  double drvalue = 0.0;
  double stvalue = 0.0;

  final vertices = <Vector2>[
    Vector2(-8.75, 25),
    Vector2(-17.5, 12.5),
    Vector2(-17.5, -12.5),
    Vector2(-8.75, -25),
    Vector2(8.75, -25),
    Vector2(17.5, -12.5),
    Vector2(17.5, 12.5),
    Vector2(8.75, 25),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final path = Path();
    final bodyPaint = Paint()..color = paint.color;
    for (var i = 0.0; i < _scaledRect.width / 4; i++) {
      bodyPaint.color = bodyPaint.color.darken(0.1);
      path.reset();
      final offsetVertices = vertices
          .map(
            (v) =>
                v.toOffset() * scale -
                Offset(i * v.x.sign, i * v.y.sign) +
                _scaledRect.bottomRight / 2,
          )
          .toList();
      path.addPolygon(offsetVertices, true);
      canvas.drawPath(path, bodyPaint);
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
    add(SpriteComponent(
        sprite: sprite,
        size: Vector2(27, 50),
        anchor: Anchor.center,
        angle: pi));
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition
      ..angle = -pi / 2;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()..set(vertices);
    final fixtureDef = FixtureDef(shape)
      ..density = 0.2
      ..restitution = 2.0;
    body.createFixture(fixtureDef);

    final jointDef = RevoluteJointDef()
      ..bodyA = body
      ..enableLimit = true
      ..lowerAngle = 0.0
      ..upperAngle = 0.0
      ..localAnchorB.setZero();

    tires = List.generate(4, (i) {
      final isFrontTire = i <= 1;
      final isLeftTire = i.isEven;
      return Tire(
        car: this,
        isFrontTire: isFrontTire,
        isLeftTire: isLeftTire,
        jointDef: jointDef,
        isTurnableTire: isFrontTire,
      );
    });

    game.world.addAll(tires);
    return body;
  }

  @override
  void update(double dt) {
    // print(body.position);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _scaledRect,
      _renderRect,
      paint,
    );
  }

  @override
  void onRemove() {
    for (final tire in tires) {
      tire.removeFromParent();
    }
  }
}
