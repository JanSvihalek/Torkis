import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() => _error =
            'Přístup ke kameře nebyl povolen.\nPovolte ho v nastavení aplikace.');
      }
      return;
    }
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
      if (mounted) setState(() => _error = 'Chyba inicializace kamery: $e');
    }
  }

  Future<void> _scan() async {
    if (!_isInitialized || _isProcessing || _controller == null) return;
    setState(() {
      _isProcessing = true;
      _result = null;
    });
    try {
      final photo = await _controller!.takePicture();
      if (!mounted) return;
      setState(() => _capturedPhoto = photo);

      final inputImage = InputImage.fromFilePath(photo.path);
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
    }
  }

  void _retry() {
    setState(() {
      _result = null;
      _capturedPhoto = null;
      _error = null;
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

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        CustomPaint(painter: _FrameOverlayPainter()),
        Align(
          alignment: const Alignment(0, 0.35),
          child: Text(
            'Namiřte kameru na ${widget.label}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              shadows: [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
        ),
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
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
          ),
      ],
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
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
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

class _FrameOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55);

    const frameWidthRatio = 0.82;
    const frameHeightRatio = 0.18;
    final left = size.width * (1 - frameWidthRatio) / 2;
    final top = size.height * (0.5 - frameHeightRatio / 2) - size.height * 0.05;
    final frameW = size.width * frameWidthRatio;
    final frameH = size.height * frameHeightRatio;
    final frameRect = Rect.fromLTWH(left, top, frameW, frameH);
    const radius = Radius.circular(8);

    // Dark overlay with transparent cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // White frame border
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, radius),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Blue corner accents
    final cornerPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const cl = 22.0;
    final r = left + frameW;
    final b = top + frameH;

    canvas.drawLine(Offset(left, top + cl), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cl, top), cornerPaint);

    canvas.drawLine(Offset(r - cl, top), Offset(r, top), cornerPaint);
    canvas.drawLine(Offset(r, top), Offset(r, top + cl), cornerPaint);

    canvas.drawLine(Offset(left, b - cl), Offset(left, b), cornerPaint);
    canvas.drawLine(Offset(left, b), Offset(left + cl, b), cornerPaint);

    canvas.drawLine(Offset(r, b - cl), Offset(r, b), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r - cl, b), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
