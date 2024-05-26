import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Background extends BodyComponent {
  final Sprite sprite;
  double num = 4.3;
  Background({required this.sprite});
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = true;
    add(SpriteComponent(
        sprite: sprite, size: sprite.srcSize * 4 / num, anchor: Anchor.center));
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    final vertices = [
      Vector2(-sprite.srcSize.x * 4 / 2 / num, sprite.srcSize.y * 4 / 2 / num),
      Vector2(sprite.srcSize.x * 4 / 2 / num, sprite.srcSize.y * 4 / 2 / num),
      Vector2(-sprite.srcSize.x * 4 / 2 / num, -sprite.srcSize.y * 4 / 2 / num),
      Vector2(sprite.srcSize.x * 4 / 2 / num, -sprite.srcSize.y * 4 / 2 / num),
    ];
    shape.set(vertices);
    final fixtureDef =
        FixtureDef(shape, friction: 20, density: 1, isSensor: true);
    final bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
