import 'package:cal_tab/widgets/barcode/scanner_instruction.dart';
import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = _scanFrameFor(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ScannerShadePainter(frame: frame)),
            Positioned(
              top: frame.bottom + 18,
              left: 24,
              right: 24,
              child: const ScannerInstruction(),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerShadePainter extends CustomPainter {
  const _ScannerShadePainter({required this.frame});

  final RRect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final shade = Paint()..color = Colors.black.withValues(alpha: 0.36);
    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(frame)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, shade);

    final outline = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(frame, outline);

    final cornerPaint = Paint()
      ..color = const Color(0xFF53E16F)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;
    const cornerLength = 34.0;
    final rect = frame.outerRect;
    const inset = 1.5;
    for (final corner in [
      rect.topLeft.translate(inset, inset),
      rect.topRight.translate(-inset, inset),
      rect.bottomRight.translate(-inset, -inset),
      rect.bottomLeft.translate(inset, -inset),
    ]) {
      final horizontalDirection = corner.dx < rect.center.dx ? 1.0 : -1.0;
      final verticalDirection = corner.dy < rect.center.dy ? 1.0 : -1.0;
      canvas.drawLine(
        corner,
        corner.translate(cornerLength * horizontalDirection, 0),
        cornerPaint,
      );
      canvas.drawLine(
        corner,
        corner.translate(0, cornerLength * verticalDirection),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerShadePainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

RRect _scanFrameFor(Size size) {
  final frameWidth = (size.width - 48).clamp(280.0, 380.0).toDouble();
  final frameHeight = frameWidth * 0.52;
  final centerY = size.height * 0.43;
  return RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: frameWidth,
      height: frameHeight,
    ),
    const Radius.circular(22),
  );
}
