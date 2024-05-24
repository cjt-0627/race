import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:jumpjump/game/car.dart';

class Tire extends BodyComponent {
  Tire({
    required this.car,
    required this.isFrontTire,
    required this.isLeftTire,
    required this.jointDef,
    this.isTurnableTire = false,
  }) : super(
          paint: Paint()
            ..color = car.paint.color
            ..strokeWidth = 0.2
            ..style = PaintingStyle.stroke,
          priority: 2,
        );

  static const double _backTireMaxDriveForce = 3000;
  static const double _frontTireMaxDriveForce = 6000;
  static const double _backTireMaxLateralImpulse = 85;
  static const double _frontTireMaxLateralImpulse = 75;

  final Car car;
  final size = Vector2(2, 5);
  late final RRect _renderRect = RRect.fromLTRBR(
    -size.x,
    -size.y,
    size.x,
    size.y,
    const Radius.circular(0.3),
  );

  late final double _maxDriveForce =
      isFrontTire ? _frontTireMaxDriveForce : _backTireMaxDriveForce;
  late final double _maxLateralImpulse =
      isFrontTire ? _frontTireMaxLateralImpulse : _backTireMaxLateralImpulse;

  // Make mutable if ice or something should be implemented
  final double _currentTraction = 1.0;

  final double _maxForwardSpeed = 2500;
  final double _maxBackwardSpeed = -400;

  final RevoluteJointDef jointDef;
  late final RevoluteJoint joint;
  final bool isTurnableTire;
  final bool isFrontTire;
  final bool isLeftTire;

  final double _lockAngle = 0.6;
  final double _turnSpeedPerSecond = 4;

  final Paint _black = BasicPalette.black.paint();

  @override
  Body createBody() {
    final jointAnchor = Vector2(
      isLeftTire ? -15.0 : 15.0,
      isFrontTire ? 20 : -22,
    );

    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = car.body.position + jointAnchor;
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape()..setAsBoxXY(0.5, 1.25);
    body.createFixtureFromShape(polygonShape).userData = this;

    jointDef.bodyB = body;
    jointDef.localAnchorA.setFrom(jointAnchor);
    world.createJoint(joint = RevoluteJoint(jointDef));
    joint.setLimits(0, 0);
    return body;
  }

  @override
  void update(double dt) {
    // if (body.isAwake) {
    _updateTurn(dt);
    _updateFriction();
    // if (!game.isGameOver) {
    print(-10);
    _updateDrive();
    // }
    // }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_renderRect, _black);
    canvas.drawRRect(_renderRect, paint);
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-body.mass)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);
    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();
    final dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(
      currentForwardNormal..scale(_currentTraction * dragForceMagnitude),
    );
  }

  void _updateDrive() {
    print(car.drvalue);
    var desiredSpeed = 0.0;
    if (car.drvalue > 0) {
      desiredSpeed = _maxForwardSpeed * car.drvalue;
    }
    if (car.drvalue < 0) {
      desiredSpeed += _maxBackwardSpeed * -car.drvalue;
    }

    final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
    final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
    var force = 0.0;
    if (desiredSpeed < currentSpeed) {
      force = -_maxDriveForce;
    } else if (desiredSpeed > currentSpeed) {
      force = _maxDriveForce;
    }

    if (force.abs() > 0) {
      body.applyForce(currentForwardNormal..scale(_currentTraction * force));
    }
  }

  void _updateTurn(double dt) {
    print(car.stvalue);
    var desiredAngle = 0.0;
    var desiredTorque = 0.0;
    var isTurning = false;
    if (car.stvalue < 0) {
      desiredTorque = 150.0 * car.stvalue;
      desiredAngle = -_lockAngle;
      isTurning = true;
    }
    if (car.stvalue > 0) {
      desiredTorque += 150.0 * car.stvalue;
      desiredAngle += _lockAngle;
      isTurning = true;
    }
    if (isTurnableTire && isTurning) {
      final turnPerTimeStep = _turnSpeedPerSecond * dt;
      final angleNow = joint.jointAngle();
      final angleToTurn =
          (desiredAngle - angleNow).clamp(-turnPerTimeStep, turnPerTimeStep);
      final angle = angleNow + angleToTurn;
      joint.setLimits(angle, angle);
    } else {
      joint.setLimits(0, 0);
    }
    body.applyTorque(desiredTorque);
  }

  // Cached Vectors to reduce unnecessary object creation.
  final Vector2 _worldLeft = Vector2(1.0, 0.0);
  final Vector2 _worldUp = Vector2(0.0, -1.0);

  Vector2 get _lateralVelocity {
    final currentRightNormal = body.worldVector(_worldLeft);
    return currentRightNormal
      ..scale(currentRightNormal.dot(body.linearVelocity));
  }

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldUp);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
