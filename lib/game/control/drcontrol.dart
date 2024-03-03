import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:jumpjump/game/red_car.dart';

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