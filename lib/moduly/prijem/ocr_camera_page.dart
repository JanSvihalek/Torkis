import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:image/image.dart' as img;
import 'dart:io';

class OcrCameraPage extends StatefulWidget {
  final String label;
  final bool numbersOnly;

  const OcrCameraPage({
    super.key,
    required this.label,
    this.numbersOnly = false,
  });

  @override
  State<OcrCameraPage> createState() => _OcrCameraPageState();
}

class _OcrCameraPageState extends State<OcrCameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _error;
  String? _result;
  XFile? _capturedPhoto;

  // Frame bounds jako zlomky rozměrů preview widgetu (0..1)
  double _frameL = 0.09;
  double _frameT = 0.365;
  double _frameR = 0.91;
  double _frameB = 0.545;
  Size _previewSize = Size.zero;

  static const _minFrameW = 0.15;
  static const _minFrameH = 0.06;
  static const _handleTouchSize = 48.0;
  static const _handleVisualSize = 14.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = 'Kamera není dostupná.');
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error =
            'Přístup ke kameře nebyl povolen.\nPovolte ho v nastavení aplikace.');
      }
    }
  }

  Future<void> _scan() async {
    if (!_isInitialized || _isProcessing || _controller == null) return;
    if (_previewSize == Size.zero) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    File? tempFile;
    try {
      final photo = await _controller!.takePicture();
      if (!mounted) return;
      setState(() => _capturedPhoto = photo);

      // Dekóduj snímek s respektováním EXIF orientace
      final bytes = await File(photo.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Nepodařilo se dekódovat snímek.');
      final oriented = img.bakeOrientation(decoded);

      // Převod frame zlomků na pixelové souřadnice snímku
      final scaleX = oriented.width / _previewSize.width;
      final scaleY = oriented.height / _previewSize.height;

      final cropX = (_frameL * _previewSize.width * scaleX)
          .round()
          .clamp(0, oriented.width - 1);
      final cropY = (_frameT * _previewSize.height * scaleY)
          .round()
          .clamp(0, oriented.height - 1);
      final cropW = ((_frameR - _frameL) * _previewSize.width * scaleX)
          .round()
          .clamp(1, oriented.width - cropX);
      final cropH = ((_frameB - _frameT) * _previewSize.height * scaleY)
          .round()
          .clamp(1, oriented.height - cropY);

      final cropped = img.copyCrop(oriented,
          x: cropX, y: cropY, width: cropW, height: cropH);

      tempFile = File(
          '${Directory.systemTemp.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(cropped));

      final inputImage = InputImage.fromFilePath(tempFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      String result = recognizedText.text;
      if (widget.numbersOnly) {
        result = result.replaceAll(RegExp(r'[^0-9]'), '');
      } else {
        result = result.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
      }

      if (mounted) {
        setState(() {
          _result = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Chyba skenování: $e';
        });
      }
    } finally {
      try {
        tempFile?.deleteSync();
      } catch (_) {}
    }
  }

  void _retry() {
    setState(() {
      _result = null;
      _capturedPhoto = null;
      _error = null;
    });
  }

  void _onCornerDrag(Offset delta, _DragCorner corner, double w, double h) {
    setState(() {
      final dx = delta.dx / w;
      final dy = delta.dy / h;
      switch (corner) {
        case _DragCorner.topLeft:
          _frameL = (_frameL + dx).clamp(0.0, _frameR - _minFrameW);
          _frameT = (_frameT + dy).clamp(0.0, _frameB - _minFrameH);
        case _DragCorner.topRight:
          _frameR = (_frameR + dx).clamp(_frameL + _minFrameW, 1.0);
          _frameT = (_frameT + dy).clamp(0.0, _frameB - _minFrameH);
        case _DragCorner.bottomLeft:
          _frameL = (_frameL + dx).clamp(0.0, _frameR - _minFrameW);
          _frameB = (_frameB + dy).clamp(_frameT + _minFrameH, 1.0);
        case _DragCorner.bottomRight:
          _frameR = (_frameR + dx).clamp(_frameL + _minFrameW, 1.0);
          _frameB = (_frameB + dy).clamp(_frameT + _minFrameH, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildMainContent()),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context, null),
          ),
          Expanded(
            child: Text(
              'Skenování ${widget.label}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_error != null && _result == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Otevřít nastavení'),
              ),
            ],
          ),
        ),
      );
    }

    if (_capturedPhoto != null && _result != null) {
      return _buildResultView();
    }

    if (!_isInitialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _previewSize = constraints.biggest;
        final w = _previewSize.width;
        final h = _previewSize.height;
        final l = _frameL * w;
        final t = _frameT * h;
        final r = _frameR * w;
        final b = _frameB * h;

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            CustomPaint(
              painter: _FramePainter(_frameL, _frameT, _frameR, _frameB),
            ),
            // Popisek pod rámečkem
            Positioned(
              left: 0,
              right: 0,
              top: b + 8,
              child: Column(
                children: [
                  Text(
                    'Namiřte kameru na ${widget.label}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Přetáhněte rohy pro změnu velikosti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ),
            // Rohové úchyty pro změnu velikosti
            _cornerHandle(l, t, _DragCorner.topLeft, w, h),
            _cornerHandle(r, t, _DragCorner.topRight, w, h),
            _cornerHandle(l, b, _DragCorner.bottomLeft, w, h),
            _cornerHandle(r, b, _DragCorner.bottomRight, w, h),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text('Rozpoznávám text...',
                          style:
                              TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cornerHandle(
      double cx, double cy, _DragCorner corner, double w, double h) {
    return Positioned(
      left: cx - _handleTouchSize / 2,
      top: cy - _handleTouchSize / 2,
      width: _handleTouchSize,
      height: _handleTouchSize,
      child: GestureDetector(
        onPanUpdate: (d) => _onCornerDrag(d.delta, corner, w, h),
        child: Center(
          child: Container(
            width: _handleVisualSize,
            height: _handleVisualSize,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 4)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = _result!.isEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(_capturedPhoto!.path), fit: BoxFit.cover),
        Container(color: Colors.black54),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEmpty ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: isEmpty ? Colors.orange : Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Rozpoznaný ${widget.label}:',
                  style:
                      const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  isEmpty ? '(nic nerozpoznáno)' : _result!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isEmpty ? Colors.red : Colors.black,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Zkusit znovu'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isEmpty
                            ? null
                            : () => Navigator.pop(context, _result),
                        icon: const Icon(Icons.check),
                        label: const Text('Potvrdit'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_result != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: GestureDetector(
        onTap: _isProcessing ? null : _scan,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: _isProcessing
                ? Colors.grey.withValues(alpha: 0.5)
                : Colors.blue.withValues(alpha: 0.85),
          ),
          child: _isProcessing
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.document_scanner,
                  color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

enum _DragCorner { topLeft, topRight, bottomLeft, bottomRight }

class _FramePainter extends CustomPainter {
  final double frameL, frameT, frameR, frameB;

  const _FramePainter(this.frameL, this.frameT, this.frameR, this.frameB);

  @override
  void paint(Canvas canvas, Size size) {
    final l = frameL * size.width;
    final t = frameT * size.height;
    final r = frameR * size.width;
    final b = frameB * size.height;
    final frameRect = Rect.fromLTRB(l, t, r, b);
    const radius = Radius.circular(8);

    // Tmavý překryv s průhledným okénkem
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Bílý rámeček
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, radius),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Modré rohové akcenty
    final cp = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const cl = 18.0;

    canvas.drawLine(Offset(l, t + cl), Offset(l, t), cp);
    canvas.drawLine(Offset(l, t), Offset(l + cl, t), cp);
    canvas.drawLine(Offset(r - cl, t), Offset(r, t), cp);
    canvas.drawLine(Offset(r, t), Offset(r, t + cl), cp);
    canvas.drawLine(Offset(l, b - cl), Offset(l, b), cp);
    canvas.drawLine(Offset(l, b), Offset(l + cl, b), cp);
    canvas.drawLine(Offset(r, b - cl), Offset(r, b), cp);
    canvas.drawLine(Offset(r, b), Offset(r - cl, b), cp);
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.frameL != frameL ||
      old.frameT != frameT ||
      old.frameR != frameR ||
      old.frameB != frameB;
}
