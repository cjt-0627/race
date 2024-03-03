import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:jumpjump/game/red_car.dart';

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