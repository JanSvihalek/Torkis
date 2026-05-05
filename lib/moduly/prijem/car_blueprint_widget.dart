import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _kBlueprintAssets = {
  'Sedan': 'assets/images/car_blueprints/sedan.svg',
  'Hatchback': 'assets/images/car_blueprints/hatchback.svg',
  'Kombi': 'assets/images/car_blueprints/kombi.svg',
};

const List<String> kTypyKaroserie = [
  'Nespecifikováno',
  'Sedan',
  'Hatchback',
  'Kombi',
];

// SVG viewBox is 1149×1369 — portrait layout.
const _kSvgAr = 1149.0 / 1369.0; // width / height ≈ 0.839

class CarBlueprintWidget extends StatefulWidget {
  final String typKaroserie;
  final Uint8List? drawing;
  final ValueChanged<Uint8List?> onDrawingChanged;
  final bool isDark;

  const CarBlueprintWidget({
    super.key,
    required this.typKaroserie,
    required this.drawing,
    required this.onDrawingChanged,
    required this.isDark,
  });

  @override
  State<CarBlueprintWidget> createState() => _CarBlueprintWidgetState();
}

class _CarBlueprintWidgetState extends State<CarBlueprintWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  // Normalized stroke coordinates (0..1) so they scale correctly between views.
  final List<_Stroke> _strokes = [];
  bool _isExporting = false;

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      widget.onDrawingChanged(bytes);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _openFullScreen(String asset) async {
    final result = await Navigator.of(context).push<List<_Stroke>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenBlueprintDialog(
          asset: asset,
          initialStrokes: _strokes
              .map((s) => _Stroke(color: s.color, points: List.from(s.points)))
              .toList(),
          isDark: widget.isDark,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _strokes.clear();
        _strokes.addAll(result);
      });
      if (_strokes.isEmpty) {
        widget.onDrawingChanged(null);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => _export());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _kBlueprintAssets[widget.typKaroserie];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schéma poškození',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E3A5F) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.isDark ? Colors.grey[800]! : Colors.grey[300]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: asset == null ? _buildNoBlueprint() : _buildPreview(asset),
        ),
      ],
    );
  }

  Widget _buildNoBlueprint() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              color: Colors.grey[400], size: 28),
          const SizedBox(width: 10),
          Text(
            'Vyberte typ karosérie pro zobrazení schématu.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(String asset) {
    return GestureDetector(
      onTap: () => _openFullScreen(asset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxH = 200.0;
          final height = math.min(maxH, constraints.maxWidth / _kSvgAr);
          final width = height * _kSvgAr;

          return Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: SizedBox(
                width: width,
                height: height,
                child: ColoredBox(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        asset,
                        width: width,
                        height: height,
                        fit: BoxFit.fill,
                      ),
                      CustomPaint(
                        size: Size(width, height),
                        painter: _StrokePainter(
                            strokes: _strokes, currentStroke: null),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.fullscreen,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-screen drawing dialog
// ---------------------------------------------------------------------------

class _FullScreenBlueprintDialog extends StatefulWidget {
  final String asset;
  final List<_Stroke> initialStrokes;
  final bool isDark;

  const _FullScreenBlueprintDialog({
    required this.asset,
    required this.initialStrokes,
    required this.isDark,
  });

  @override
  State<_FullScreenBlueprintDialog> createState() =>
      _FullScreenBlueprintDialogState();
}

class _FullScreenBlueprintDialogState
    extends State<_FullScreenBlueprintDialog> {
  late List<_Stroke> _strokes;
  _Stroke? _currentStroke;
  Color _penColor = Colors.red;

  static const List<Color> _colors = [Colors.red, Colors.orange, Colors.blue];

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  void _onPanStart(DragStartDetails d, Size canvasSize) {
    final norm = Offset(
      d.localPosition.dx / canvasSize.width,
      d.localPosition.dy / canvasSize.height,
    );
    setState(() => _currentStroke = _Stroke(color: _penColor, points: [norm]));
  }

  void _onPanUpdate(DragUpdateDetails d, Size canvasSize) {
    if (_currentStroke == null) return;
    final norm = Offset(
      d.localPosition.dx / canvasSize.width,
      d.localPosition.dy / canvasSize.height,
    );
    setState(() => _currentStroke!.points.add(norm));
  }

  void _onPanEnd(DragEndDetails _) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF1E3A5F) : Colors.white;
    final iconColor = widget.isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(_strokes),
        ),
        title: const Text('Schéma poškození'),
        actions: [
          ..._colors.map(
            (c) => GestureDetector(
              onTap: () => setState(() => _penColor = c),
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _penColor == c ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: _penColor == c
                      ? [
                          BoxShadow(
                              color: c.withValues(alpha: 0.5), blurRadius: 6)
                        ]
                      : [],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            tooltip: 'Zpět',
            onPressed: _strokes.isEmpty ? null : _undo,
            color: iconColor,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Smazat vše',
            onPressed: _strokes.isEmpty ? null : _clear,
            color: iconColor,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final W = constraints.maxWidth;
          final H = constraints.maxHeight;
          // Largest rectangle with SVG aspect ratio that fits W×H.
          // SVG is portrait (ar < 1), so typically width-constrained on phones.
          final svgW = math.min(W, H * _kSvgAr);
          final svgH = svgW / _kSvgAr;
          final canvasSize = Size(svgW, svgH);

          return Center(
            child: SizedBox(
              width: svgW,
              height: svgH,
              child: ColoredBox(
                color: Colors.white,
                child: GestureDetector(
                  onPanStart: (d) => _onPanStart(d, canvasSize),
                  onPanUpdate: (d) => _onPanUpdate(d, canvasSize),
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        widget.asset,
                        width: svgW,
                        height: svgH,
                        fit: BoxFit.fill,
                      ),
                      CustomPaint(
                        size: Size(svgW, svgH),
                        painter: _StrokePainter(
                          strokes: _strokes,
                          currentStroke: _currentStroke,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data & painter
// ---------------------------------------------------------------------------

class _Stroke {
  final Color color;
  final List<Offset> points; // normalized 0..1

  _Stroke({required this.color, required this.points});
}

class _StrokePainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;

  _StrokePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [
      ...strokes,
      if (currentStroke != null) currentStroke!
    ]) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final first = stroke.points.first;
      final path = Path()
        ..moveTo(first.dx * size.width, first.dy * size.height);
      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i];
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) => true;
}
