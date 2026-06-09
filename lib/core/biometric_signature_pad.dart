import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'biometric_signature.dart';

/// Ovladač biometrického podpisového plátna.
///
/// Drží zaznamenané tahy včetně časování a tlaku. Rozhraní je úmyslně
/// kompatibilní s původním `SignatureController` (isEmpty / isNotEmpty /
/// clear / toPngBytes), aby integrace byla minimální.
class BiometricSignatureController extends ChangeNotifier {
  final double penStrokeWidth;
  final Color penColor;

  BiometricSignatureController({
    this.penStrokeWidth = 3.0,
    this.penColor = Colors.black,
  });

  final List<SignatureStroke> _strokes = [];
  SignatureStroke? _active;
  Size canvasSize = Size.zero;
  int? _startEpochMs;

  bool get isEmpty => _strokes.isEmpty && _active == null;
  bool get isNotEmpty => !isEmpty;

  /// Tahy pro vykreslení (hotové + právě kreslený).
  List<SignatureStroke> get visibleStrokes =>
      [..._strokes, if (_active != null) _active!];

  // ── Záznam ─────────────────────────────────────────────────────────────

  void startStroke(Offset pos, {double? pressure, double? radius}) {
    _startEpochMs ??= DateTime.now().millisecondsSinceEpoch;
    _active = SignatureStroke(points: [_makePoint(pos, pressure, radius)]);
    notifyListeners();
  }

  void appendPoint(Offset pos, {double? pressure, double? radius}) {
    if (_active == null) return;
    _active!.points.add(_makePoint(pos, pressure, radius));
    notifyListeners();
  }

  void endStroke() {
    if (_active == null) return;
    if (_active!.points.isNotEmpty) _strokes.add(_active!);
    _active = null;
    notifyListeners();
  }

  SignaturePoint _makePoint(Offset pos, double? pressure, double? radius) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return SignaturePoint(
      x: pos.dx,
      y: pos.dy,
      t: now - (_startEpochMs ?? now),
      // Filtrujeme nesmyslné/konstantní hodnoty z kapacitních displejů:
      // 1.0 je typická „falešná" konstanta u prstu.
      pressure: (pressure != null && pressure > 0 && pressure != 1.0)
          ? pressure
          : null,
      radius: (radius != null && radius > 0) ? radius : null,
    );
  }

  void clear() {
    _strokes.clear();
    _active = null;
    _startEpochMs = null;
    notifyListeners();
  }

  // ── Export ───────────────────────────────────────────────────────────────

  /// Sestaví biometrická data. [metadata] dodá volající (zařízení, verze…).
  BiometricSignature buildBiometricSignature({
    required String deviceModel,
    required String platform,
    required String appVersion,
    required String locale,
  }) {
    return BiometricSignature(
      strokes: _strokes
          .map((s) => SignatureStroke(points: List.of(s.points)))
          .toList(),
      canvasWidth: canvasSize.width,
      canvasHeight: canvasSize.height,
      capturedAtMs: DateTime.now().toUtc().millisecondsSinceEpoch,
      deviceModel: deviceModel,
      platform: platform,
      appVersion: appVersion,
      locale: locale,
    );
  }

  /// Vyrenderuje podpis do PNG (bílé pozadí), kompatibilní s původním API.
  Future<Uint8List?> toPngBytes({double pixelRatio = 3.0}) async {
    if (isEmpty) return null;
    final size =
        canvasSize == Size.zero ? const Size(600, 250) : canvasSize;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);
    canvas.scale(pixelRatio);

    final paint = Paint()
      ..color = penColor
      ..strokeWidth = penStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    _paintStrokes(canvas, visibleStrokes, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  static void _paintStrokes(
      Canvas canvas, List<SignatureStroke> strokes, Paint paint) {
    for (final s in strokes) {
      if (s.points.isEmpty) continue;
      if (s.points.length == 1) {
        final p = s.points.first;
        canvas.drawPoints(
            ui.PointMode.points, [Offset(p.x, p.y)], paint);
        continue;
      }
      final path = Path()..moveTo(s.points.first.x, s.points.first.y);
      for (int i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].x, s.points[i].y);
      }
      canvas.drawPath(path, paint);
    }
  }
}

/// Plátno pro biometrický podpis. Používá [Listener] (ne GestureDetector),
/// aby mělo přístup k tlaku (`pressure`) a ploše dotyku (`radiusMajor`).
class BiometricSignaturePad extends StatelessWidget {
  final BiometricSignatureController controller;
  final double height;
  final Color backgroundColor;

  const BiometricSignaturePad({
    super.key,
    required this.controller,
    this.height = 250,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, height);
      controller.canvasSize = size;
      // GestureDetector obsadí gesture arena a zabrání ScrollView
      // ve scrollování během kreslení podpisu.
      // Listener níže stále dostává raw eventy včetně tlaku a poloměru.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {},
        onPanUpdate: (_) {},
        onPanEnd: (_) {},
        child: Listener(
          onPointerDown: (e) => controller.startStroke(
            e.localPosition,
            pressure: e.pressure,
            radius: e.radiusMajor,
          ),
          onPointerMove: (e) => controller.appendPoint(
            e.localPosition,
            pressure: e.pressure,
            radius: e.radiusMajor,
          ),
          onPointerUp: (_) => controller.endStroke(),
          onPointerCancel: (_) => controller.endStroke(),
          child: Container(
          width: size.width,
          height: height,
          color: backgroundColor,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _PadPainter(controller),
            ),
          ),
        ),
      ),
    );
    });
  }
}

class _PadPainter extends CustomPainter {
  final BiometricSignatureController controller;
  _PadPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = controller.penColor
      ..strokeWidth = controller.penStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    BiometricSignatureController._paintStrokes(
        canvas, controller.visibleStrokes, paint);
  }

  @override
  bool shouldRepaint(_PadPainter oldDelegate) => true;
}
