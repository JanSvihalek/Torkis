import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';

enum _DrawMode { freehand, circle, rectangle, arrow }

class _Annotation {
  final List<Offset> points; // normalizované 0..1
  // freehand: všechny body tahu; tvary: [start, end]
  final Color color;
  final String label;
  final int number;
  final _DrawMode mode;

  _Annotation({
    required this.points,
    required this.color,
    required this.label,
    required this.number,
    required this.mode,
  });

  /// Pravý horní roh ohraničujícího obdélníku — pin se zobrazí vedle.
  Offset get pinAnchor {
    if (points.isEmpty) return Offset.zero;
    double minY = double.infinity;
    double maxX = -double.infinity;
    for (final p in points) {
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
    }
    return Offset(maxX, minY);
  }
}

/// Full-screen editor pro kreslení anotací poškození přímo na fotografii.
/// Podporuje volnou kresbu, elipsu, obdélník a šipku.
/// Vrací [Uint8List] s PNG s vypálenými anotacemi, nebo null při zavření.
class PhotoAnnotationEditor extends StatefulWidget {
  final XFile photo;
  final bool isDark;
  final List<String> predefinedLabels;

  const PhotoAnnotationEditor({
    super.key,
    required this.photo,
    required this.isDark,
    this.predefinedLabels = const [],
  });

  static Future<Uint8List?> open(
    BuildContext context,
    XFile photo,
    bool isDark, {
    List<String> predefinedLabels = const [],
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PhotoAnnotationEditor(
          photo: photo,
          isDark: isDark,
          predefinedLabels: predefinedLabels,
        ),
      ),
    );
  }

  @override
  State<PhotoAnnotationEditor> createState() =>
      _PhotoAnnotationEditorState();
}

class _PhotoAnnotationEditorState extends State<PhotoAnnotationEditor> {
  final GlobalKey _repaintKey = GlobalKey();
  final List<_Annotation> _annotations = [];

  // Freehand stav
  List<Offset>? _currentStroke;

  // Stav pro tvary (normalizované 0..1)
  Offset? _shapeStart;
  Offset? _shapeEnd;

  _DrawMode _drawMode = _DrawMode.freehand;
  Color _penColor = Colors.red;
  bool _isExporting = false;

  ui.Image? _image;
  Size? _imageSize;
  bool _loading = true;

  final _labelCtrl = TextEditingController();

  static const List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.photo.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      if (mounted) {
        setState(() {
          _image = img;
          _imageSize =
              Size(img.width.toDouble(), img.height.toDouble());
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Offset _normalize(Offset pos, Size canvas) => Offset(
        pos.dx.clamp(0.0, canvas.width) / canvas.width,
        pos.dy.clamp(0.0, canvas.height) / canvas.height,
      );

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d, Size canvas) {
    final norm = _normalize(d.localPosition, canvas);
    if (_drawMode == _DrawMode.freehand) {
      setState(() => _currentStroke = [norm]);
    } else {
      setState(() {
        _shapeStart = norm;
        _shapeEnd = norm;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d, Size canvas) {
    final norm = _normalize(d.localPosition, canvas);
    if (_drawMode == _DrawMode.freehand) {
      if (_currentStroke == null) return;
      setState(() => _currentStroke!.add(norm));
    } else {
      setState(() => _shapeEnd = norm);
    }
  }

  Future<void> _onPanEnd(DragEndDetails _) async {
    if (_drawMode == _DrawMode.freehand) {
      final stroke = _currentStroke;
      setState(() => _currentStroke = null);
      if (stroke == null || stroke.length < 2) return;
      await _promptLabel(stroke, _DrawMode.freehand);
    } else {
      final start = _shapeStart;
      final end = _shapeEnd;
      setState(() {
        _shapeStart = null;
        _shapeEnd = null;
      });
      if (start == null || end == null) return;
      // Ignoruj příliš malé tahy (klepnutí bez pohybu)
      final dx = (end.dx - start.dx).abs();
      final dy = (end.dy - start.dy).abs();
      if (dx < 0.01 && dy < 0.01) return;
      await _promptLabel([start, end], _drawMode);
    }
  }

  Future<void> _promptLabel(
      List<Offset> points, _DrawMode mode) async {
    _labelCtrl.clear();
    final label = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LabelDialog(
        controller: _labelCtrl,
        predefinedLabels: widget.predefinedLabels,
      ),
    );
    if (label == null || label.isEmpty) return;
    setState(() => _annotations.add(_Annotation(
          points: points,
          color: _penColor,
          label: label,
          number: _annotations.length + 1,
          mode: mode,
        )));
  }

  void _undo() {
    if (_annotations.isEmpty) return;
    setState(() => _annotations.removeLast());
  }

  void _clear() => setState(() => _annotations.clear());

  Future<void> _save() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (mounted) Navigator.of(context).pop(bytes);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bgColor =
        widget.isDark ? const Color(0xFF0B1A2E) : Colors.grey[100]!;
    final iconColor = widget.isDark ? Colors.white70 : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      // Vlastní horní lišta (ne Material AppBar). Scaffold bez `appBar` nemůže
      // z principu vykreslit žádné systémové tlačítko zpět, takže nemůže dojít
      // k překryvu se zavíracím křížkem.
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _image == null
                ? Center(child: Text(l10n.anotChybaNacteni))
                : Column(
                    children: [
                      _buildTopBar(l10n, bgColor, iconColor),
                      Expanded(
                        child: Stack(
                          children: [
                            // Plátno s RepaintBoundary (jen tohle se exportuje)
                            Positioned.fill(child: _buildCanvas()),
                            // Plovoucí panel nástrojů — MIMO RepaintBoundary,
                            // takže se nevypálí do uložené fotky.
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildToolPanel(),
                            ),
                          ],
                        ),
                      ),
                      if (_annotations.isNotEmpty) _buildLegend(),
                    ],
                  ),
      ),
    );
  }

  /// Vlastní horní lišta editoru — křížek vlevo, akce (zpět/smazat/uložit)
  /// vpravo. Záměrně bez Material AppBaru, aby nemohlo vzniknout systémové
  /// tlačítko zpět.
  Widget _buildTopBar(
      AppLocalizations l10n, Color bgColor, Color? iconColor) {
    return Container(
      height: 56,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.anotZavritBezUlozeni,
            color: iconColor,
            onPressed: () async {
              if (_annotations.isEmpty) {
                Navigator.of(context).pop(null);
                return;
              }
              final save = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.anotTitle),
                  content: Text(l10n.anotNeulozenePomoc),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.anotZahodi),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.anotUlozit),
                    ),
                  ],
                ),
              );
              if (!mounted) return;
              if (save == true) {
                await _save();
              } else if (save == false) {
                Navigator.of(context).pop(null);
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              l10n.anotTitle,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            tooltip: l10n.anotZrusitPosledni,
            color: iconColor,
            onPressed: _annotations.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: l10n.anotSmazatVse,
            color: iconColor,
            onPressed: _annotations.isEmpty ? null : _clear,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton(
              onPressed: _isExporting ? null : _save,
              child: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.anotUlozit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      final ar = _imageSize!.width / _imageSize!.height;
      final W = constraints.maxWidth;
      final H = constraints.maxHeight;
      final canvasW = H * ar > W ? W : H * ar;
      final canvasH = canvasW / ar;
      final canvasSize = Size(canvasW, canvasH);

      return Center(
        child: RepaintBoundary(
          key: _repaintKey,
          child: SizedBox(
            width: canvasW,
            height: canvasH,
            child: GestureDetector(
              onPanStart: (d) => _onPanStart(d, canvasSize),
              onPanUpdate: (d) => _onPanUpdate(d, canvasSize),
              onPanEnd: _onPanEnd,
              child: Stack(
                children: [
                  kIsWeb
                      ? Image.network(
                          widget.photo.path,
                          width: canvasW,
                          height: canvasH,
                          fit: BoxFit.fill,
                        )
                      : RawImage(
                          image: _image,
                          width: canvasW,
                          height: canvasH,
                          fit: BoxFit.fill,
                        ),
                  CustomPaint(
                    size: canvasSize,
                    painter: _AnnotationPainter(
                      annotations: _annotations,
                      currentFreehandStroke: _currentStroke,
                      shapeStart: _shapeStart,
                      shapeEnd: _shapeEnd,
                      drawMode: _drawMode,
                      currentColor: _penColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Plovoucí panel v pravém horním rohu — výběr typu značení i barvy
  /// na jednom místě.
  Widget _buildToolPanel() {
    final l10n = AppLocalizations.of(context);
    final panelBg = widget.isDark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.92);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeBtn(_DrawMode.freehand, Icons.edit_outlined, l10n.anotVolnaKresba),
          _modeBtn(_DrawMode.circle, Icons.circle_outlined, l10n.anotElipsa),
          _modeBtn(_DrawMode.rectangle, Icons.crop_square_outlined, l10n.anotObdelnik),
          _modeBtn(_DrawMode.arrow, Icons.arrow_forward_rounded, l10n.anotSipka),
          Container(
            height: 1,
            width: 28,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.withValues(alpha: 0.4),
          ),
          ..._colors.map(_colorDot),
        ],
      ),
    );
  }

  Widget _colorDot(Color c) {
    final selected = _penColor == c;
    return GestureDetector(
      onTap: () => setState(() => _penColor = c),
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? (widget.isDark ? Colors.white : Colors.black87)
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 6)]
              : [],
        ),
      ),
    );
  }

  Widget _modeBtn(_DrawMode mode, IconData icon, String tooltip) {
    final selected = _drawMode == mode;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => setState(() => _drawMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: selected
                ? _penColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _penColor
                  : Colors.grey.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Icon(icon,
              size: 22,
              color: selected ? _penColor : Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final bg = widget.isDark ? const Color(0xFF1E3A5F) : Colors.white;
    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      color: bg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _annotations.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 8, thickness: 0.5),
        itemBuilder: (context, i) {
          final a = _annotations[i];
          return Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: a.color,
                child: Text(
                  '${a.number}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  a.label,
                  style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark
                          ? Colors.white
                          : Colors.black87),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog pro zadání popisu
// ---------------------------------------------------------------------------

class _LabelDialog extends StatefulWidget {
  final TextEditingController controller;
  final List<String> predefinedLabels;

  const _LabelDialog({
    required this.controller,
    required this.predefinedLabels,
  });

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.anotPopisTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.predefinedLabels.isNotEmpty) ...[
            Text(l10n.anotVzory,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.predefinedLabels
                  .map((label) => ActionChip(
                        label: Text(label,
                            style: const TextStyle(fontSize: 12)),
                        onPressed: () =>
                            Navigator.of(context).pop(label),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: widget.controller,
            autofocus: widget.predefinedLabels.isEmpty,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.anotVlastniPopis,
              isDense: true,
            ),
            onSubmitted: (v) {
              final t = v.trim();
              if (t.isNotEmpty) Navigator.of(context).pop(t);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.anotZrusit),
        ),
        ElevatedButton(
          onPressed: () {
            final t = widget.controller.text.trim();
            if (t.isNotEmpty) Navigator.of(context).pop(t);
          },
          child: Text(l10n.anotUlozit),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _AnnotationPainter extends CustomPainter {
  final List<_Annotation> annotations;
  final List<Offset>? currentFreehandStroke;
  final Offset? shapeStart;
  final Offset? shapeEnd;
  final _DrawMode drawMode;
  final Color currentColor;

  _AnnotationPainter({
    required this.annotations,
    required this.currentFreehandStroke,
    required this.shapeStart,
    required this.shapeEnd,
    required this.drawMode,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Hotové anotace
    for (final a in annotations) {
      _drawShape(canvas, size, a.points, a.color, a.mode);
      _drawPin(canvas, size, a.pinAnchor, a.color, a.number, a.label);
    }

    // Průběžný náhled — freehand
    if (currentFreehandStroke != null &&
        currentFreehandStroke!.length >= 2) {
      _drawFreehand(canvas, size, currentFreehandStroke!, currentColor);
    }

    // Průběžný náhled — tvar
    if (shapeStart != null && shapeEnd != null) {
      _drawShape(
          canvas, size, [shapeStart!, shapeEnd!], currentColor, drawMode,
          preview: true);
    }
  }

  void _drawShape(Canvas canvas, Size size, List<Offset> pts, Color color,
      _DrawMode mode, {bool preview = false}) {
    switch (mode) {
      case _DrawMode.freehand:
        _drawFreehand(canvas, size, pts, color);
      case _DrawMode.circle:
        if (pts.length >= 2) _drawEllipse(canvas, size, pts[0], pts[1], color);
      case _DrawMode.rectangle:
        if (pts.length >= 2) _drawRect(canvas, size, pts[0], pts[1], color);
      case _DrawMode.arrow:
        if (pts.length >= 2) _drawArrow(canvas, size, pts[0], pts[1], color);
    }
  }

  Paint _strokePaint(Color color) => Paint()
    ..color = color.withValues(alpha: 0.75)
    ..strokeWidth = 4.0
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  void _drawFreehand(
      Canvas canvas, Size size, List<Offset> pts, Color color) {
    if (pts.length < 2) return;
    final path = Path()
      ..moveTo(pts.first.dx * size.width, pts.first.dy * size.height);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * size.width, pts[i].dy * size.height);
    }
    canvas.drawPath(path, _strokePaint(color));
  }

  void _drawEllipse(Canvas canvas, Size size, Offset p0, Offset p1,
      Color color) {
    final rect = Rect.fromPoints(
      Offset(p0.dx * size.width, p0.dy * size.height),
      Offset(p1.dx * size.width, p1.dy * size.height),
    );
    canvas.drawOval(rect, _strokePaint(color));
  }

  void _drawRect(Canvas canvas, Size size, Offset p0, Offset p1,
      Color color) {
    final rect = Rect.fromPoints(
      Offset(p0.dx * size.width, p0.dy * size.height),
      Offset(p1.dx * size.width, p1.dy * size.height),
    );
    canvas.drawRect(rect, _strokePaint(color));
  }

  void _drawArrow(Canvas canvas, Size size, Offset p0, Offset p1,
      Color color) {
    final x0 = p0.dx * size.width;
    final y0 = p0.dy * size.height;
    final x1 = p1.dx * size.width;
    final y1 = p1.dy * size.height;

    final paint = _strokePaint(color);
    canvas.drawLine(Offset(x0, y0), Offset(x1, y1), paint);

    // Hrot šipky
    final angle = math.atan2(y1 - y0, x1 - x0);
    const headLen = 18.0;
    const headAngle = 0.42; // radiány
    final path = Path()
      ..moveTo(x1, y1)
      ..lineTo(
          x1 - headLen * math.cos(angle - headAngle),
          y1 - headLen * math.sin(angle - headAngle))
      ..moveTo(x1, y1)
      ..lineTo(
          x1 - headLen * math.cos(angle + headAngle),
          y1 - headLen * math.sin(angle + headAngle));
    canvas.drawPath(path, paint);
  }

  /// Pin s číslem a popisem vpravo/vlevo od kotevního bodu.
  void _drawPin(Canvas canvas, Size size, Offset anchor, Color color,
      int number, String label) {
    const r = 13.0;
    const gap = 5.0;

    final cx =
        (anchor.dx * size.width + gap + r).clamp(r, size.width - r);
    final cy =
        (anchor.dy * size.height - gap - r).clamp(r, size.height - r);

    canvas.drawCircle(
        Offset(cx, cy), r + 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);

    final numTp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    numTp.paint(
        canvas, Offset(cx - numTp.width / 2, cy - numTp.height / 2));

    if (label.isEmpty) return;
    const maxLen = 28;
    final displayLabel = label.length > maxLen
        ? '${label.substring(0, maxLen - 1)}…'
        : label;

    final labelTp = TextPainter(
      text: TextSpan(
        text: displayLabel,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 180);

    const padH = 6.0;
    const padV = 3.0;
    final bgW = labelTp.width + padH * 2;
    final bgH = labelTp.height + padV * 2;

    double bgLeft = cx + r + gap;
    if (bgLeft + bgW > size.width - 2) bgLeft = cx - r - gap - bgW;
    bgLeft = bgLeft.clamp(2.0, size.width - bgW - 2);
    final bgTop = (cy - bgH / 2).clamp(2.0, size.height - bgH - 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bgLeft, bgTop, bgW, bgH),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );
    labelTp.paint(canvas, Offset(bgLeft + padH, bgTop + padV));
  }

  @override
  bool shouldRepaint(_AnnotationPainter old) => true;
}
