library project_event_clock;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_event_clock/AngularItem.dart';

class Clock extends StatefulWidget {
  final List<AngularItem> angularItemList;
  final double currentPercentage;
  final Color? clockFrameColor;
  final Color? clockScaleColor;
  final Color? clockHandColor;
  final Color? clockSectorColor;
  const Clock({
    Key? key,
    required this.angularItemList,
    required this.currentPercentage,
    this.clockFrameColor,
    this.clockScaleColor,
    this.clockHandColor,
    this.clockSectorColor,
  }) : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  @override
  Widget build(BuildContext context) {
    final parentSize = MediaQuery.of(context).size;
    final innerRadius = parentSize.width * 0.7;
    double calulateXPosition(double percentage) {
      final double radius = 2 * pi * percentage;
      final double originX = parentSize.width * 0.5;

      final double dx = originX + cos(radius - pi / 2) * innerRadius / 2;
      return dx;
    }

    double calulateYPosition(double percentage) {
      final double radius = 2 * pi * percentage;
      final double originY = parentSize.width * 0.5;
      final double dy = originY + sin(radius - pi / 2) * innerRadius / 2;
      return dy;
    }

    return SizedBox(
      height: parentSize.width,
      width: parentSize.width,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: innerRadius,
              width: innerRadius,
              child: CustomPaint(
                painter: _ClockPainter(
                  scaleNumber: 12,
                  percentage: widget.currentPercentage,
                  clockFrameColor: widget.clockFrameColor,
                  clockScaleColor: widget.clockScaleColor,
                  clockHandColor: widget.clockHandColor,
                  clockSectorColor: widget.clockSectorColor,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          ...widget.angularItemList.map(
            (e) => Positioned(
              child: SizedBox(
                width: parentSize.width * 0.08,
                height: parentSize.width * 0.08,
                child: e.child,
              ),
              left: calulateXPosition(e.percentage) - parentSize.width * 0.04,
              top: calulateYPosition(e.percentage) - parentSize.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final Color clockFrameColor;
  final Color clockScaleColor;
  final Color clockHandColor;
  final Color clockSectorColor;
  final int scaleNumber;
  final double percentage;
  _ClockPainter({
    required this.scaleNumber,
    required this.percentage,
    Color? clockFrameColor,
    Color? clockScaleColor,
    Color? clockHandColor,
    Color? clockSectorColor,
  })  : clockFrameColor = clockFrameColor ?? Colors.black,
        clockHandColor = clockHandColor ?? Colors.black,
        clockScaleColor = clockScaleColor ?? Colors.black,
        clockSectorColor = clockSectorColor ?? Colors.blue;

  @override
  void paint(Canvas canvas, Size size) {
    final parentHeight = size.height;
    final parentWidth = size.width;
    final center = Offset(parentWidth * 0.5, parentHeight * 0.5);
    final outterRadius = parentWidth / 2;
    drawFrame(
      canvas: canvas,
      center: center,
      r: outterRadius,
    );
    drawMajorScale(
      number: scaleNumber,
      center: center,
      r: outterRadius,
      canvas: canvas,
    );
    drawHandIndicator(
      percentage: percentage,
      center: center,
      r: outterRadius,
      canvas: canvas,
    );
    drawSector(
      percentage: percentage,
      offset: 0,
      center: center,
      r: outterRadius,
      canvas: canvas,
    );
  }

  void drawFrame({
    required Canvas canvas,
    required Offset center,
    required double r,
  }) {
    Paint clockOutterEdgePaint = Paint()
      ..color = clockFrameColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, r, clockOutterEdgePaint);
  }

  void drawMajorScale({
    required int number,
    required Offset center,
    required double r,
    required Canvas canvas,
  }) {
    double innerRadius = r - 10;
    double outerRadius = r;
    Paint majorScalePaint = Paint()
      ..color = clockScaleColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < number; i++) {
      double currentDegree = i * pi * 2 / number - pi / 2;
      double x1 = center.dx + cos(currentDegree) * innerRadius;
      double x2 = center.dx + cos(currentDegree) * outerRadius;
      double y1 = center.dy + sin(currentDegree) * innerRadius;
      double y2 = center.dy + sin(currentDegree) * outerRadius;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), majorScalePaint);
    }
    // canvas.drawLine(p1, p2, paint);
  }

  void drawHandIndicator({
    required double percentage,
    required Offset center,
    required double r,
    required Canvas canvas,
  }) {
    Paint clockHandPaint = Paint()
      ..color = clockHandColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    double currentDegree = -pi / 2 + percentage * 2 * pi;
    double x1 = center.dx;
    double x2 = center.dx + cos(currentDegree) * r;
    double y1 = center.dy;
    double y2 = center.dy + sin(currentDegree) * r;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), clockHandPaint);
  }

  void drawSector({
    required double percentage,
    required double offset,
    required Offset center,
    required double r,
    required Canvas canvas,
  }) {
    Paint sectorPaint = Paint()
      ..color = clockSectorColor.withAlpha(100)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -pi / 2,
        2 * pi * percentage, true, sectorPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return percentage != oldDelegate.percentage;
  }
}
