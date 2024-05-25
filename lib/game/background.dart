import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:forge2d/src/dynamics/body.dart';

class Background extends BodyComponent {
  final Sprite sprite;
  Background({required this.sprite});
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = true;
    add(SpriteComponent(
        sprite: sprite, size: sprite.srcSize * 4 / 5, anchor: Anchor.center));
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    final vertices = [
      Vector2(-sprite.srcSize.x * 4 / 2 / 5, sprite.srcSize.y * 4 / 2 / 5),
      Vector2(sprite.srcSize.x * 4 / 2 / 5, sprite.srcSize.y * 4 / 2 / 5),
      Vector2(-sprite.srcSize.x * 4 / 2 / 5, -sprite.srcSize.y * 4 / 2 / 5),
      Vector2(sprite.srcSize.x * 4 / 2 / 5, -sprite.srcSize.y * 4 / 2 / 5),
    ];
    shape.set(vertices);
    final fixtureDef =
        FixtureDef(shape, friction: 20, density: 1, isSensor: true);
    final bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
