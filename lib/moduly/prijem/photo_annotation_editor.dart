import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class _Annotation {
  final List<Offset> points; // normalizované 0..1
  final Color color;
  final String label;
  final int number;

  _Annotation({
    required this.points,
    required this.color,
    required this.label,
    required this.number,
  });

  Offset get centroid {
    if (points.isEmpty) return Offset.zero;
    double x = 0, y = 0;
    for (final p in points) {
      x += p.dx;
      y += p.dy;
    }
    return Offset(x / points.length, y / points.length);
  }
}

/// Full-screen editor pro kreslení anotací poškození přímo na fotografii.
/// Vrací [Uint8List] s PNG obrázkem, do kterého jsou anotace vypáleny,
/// nebo null pokud uživatel editor zavřel bez uložení.
class PhotoAnnotationEditor extends StatefulWidget {
  final XFile photo;
  final bool isDark;

  const PhotoAnnotationEditor({
    super.key,
    required this.photo,
    required this.isDark,
  });

  static Future<Uint8List?> open(
      BuildContext context, XFile photo, bool isDark) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            PhotoAnnotationEditor(photo: photo, isDark: isDark),
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
  List<Offset>? _currentStroke;
  bool _isExporting = false;

  Uint8List? _imageBytes;
  Size? _imageSize;
  bool _loading = true;

  Color _penColor = Colors.red;
  static const List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];

  final _labelCtrl = TextEditingController();

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
          _imageBytes = bytes;
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

  void _onPanStart(DragStartDetails d, Size canvas) {
    setState(
        () => _currentStroke = [_normalize(d.localPosition, canvas)]);
  }

  void _onPanUpdate(DragUpdateDetails d, Size canvas) {
    if (_currentStroke == null) return;
    setState(
        () => _currentStroke!.add(_normalize(d.localPosition, canvas)));
  }

  Future<void> _onPanEnd(DragEndDetails _) async {
    final stroke = _currentStroke;
    setState(() => _currentStroke = null);
    if (stroke == null || stroke.length < 2) return;

    _labelCtrl.clear();
    final label = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Popis poškození'),
        content: TextField(
          controller: _labelCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Popište poškození...',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Zrušit'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, _labelCtrl.text.trim()),
            child: const Text('Uložit'),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;
    setState(() => _annotations.add(_Annotation(
          points: stroke,
          color: _penColor,
          label: label,
          number: _annotations.length + 1,
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

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isDark ? const Color(0xFF0B1A2E) : Colors.grey[100]!;
    final iconColor = widget.isDark ? Colors.white70 : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Zavřít bez uložení',
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: const Text('Označení poškození'),
        actions: [
          ..._colors.map((c) => GestureDetector(
                onTap: () => setState(() => _penColor = c),
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 14),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _penColor == c
                          ? Colors.white
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: _penColor == c
                        ? [
                            BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 6)
                          ]
                        : [],
                  ),
                ),
              )),
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            tooltip: 'Zrušit poslední',
            color: iconColor,
            onPressed: _annotations.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Smazat vše',
            color: iconColor,
            onPressed: _annotations.isEmpty ? null : _clear,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton(
              onPressed: _isExporting ? null : _save,
              child: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Uložit'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _imageBytes == null
              ? const Center(child: Text('Nepodařilo se načíst fotografii.'))
              : Column(
                  children: [
                    Expanded(child: _buildCanvas()),
                    if (_annotations.isNotEmpty) _buildLegend(),
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
                      : Image.memory(
                          _imageBytes!,
                          width: canvasW,
                          height: canvasH,
                          fit: BoxFit.fill,
                        ),
                  CustomPaint(
                    size: canvasSize,
                    painter: _AnnotationPainter(
                      annotations: _annotations,
                      currentStroke: _currentStroke,
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

  Widget _buildLegend() {
    final bg =
        widget.isDark ? const Color(0xFF1E3A5F) : Colors.white;
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
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
                    fontWeight: FontWeight.bold,
                  ),
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
                        : Colors.black87,
                  ),
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

class _AnnotationPainter extends CustomPainter {
  final List<_Annotation> annotations;
  final List<Offset>? currentStroke;
  final Color currentColor;

  _AnnotationPainter({
    required this.annotations,
    required this.currentStroke,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final a in annotations) {
      _drawStroke(canvas, size, a.points, a.color);
      _drawPin(canvas, size, a.centroid, a.color, a.number);
    }
    if (currentStroke != null && currentStroke!.length >= 2) {
      _drawStroke(canvas, size, currentStroke!, currentColor);
    }
  }

  void _drawStroke(
      Canvas canvas, Size size, List<Offset> pts, Color color) {
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(pts.first.dx * size.width, pts.first.dy * size.height);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * size.width, pts[i].dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  void _drawPin(Canvas canvas, Size size, Offset norm, Color color,
      int number) {
    final cx = norm.dx * size.width;
    final cy = norm.dy * size.height;
    const r = 13.0;

    // Bílý obrys pro kontrast s tmavým i světlým pozadím
    canvas.drawCircle(
        Offset(cx, cy), r + 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);

    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_AnnotationPainter old) => true;
}
