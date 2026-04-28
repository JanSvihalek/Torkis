import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// Vlastní kamera pro pořízení více snímků bez potvrzování každého foto.
class MultiShotCameraPage extends StatefulWidget {
  const MultiShotCameraPage({super.key});

  @override
  State<MultiShotCameraPage> createState() => _MultiShotCameraPageState();
}

class _MultiShotCameraPageState extends State<MultiShotCameraPage> {
  CameraController? _controller;
  final List<XFile> _photos = [];
  bool _isCapturing = false;
  bool _isInitialized = false;
  String? _error;

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
      debugPrint('Camera init error: $e');
      if (mounted) setState(() => _error = 'Chyba inicializace kamery: $e');
    }
  }

  Future<void> _capture() async {
    if (!_isInitialized || _isCapturing || _controller == null) return;
    setState(() => _isCapturing = true);
    try {
      final photo = await _controller!.takePicture();
      if (mounted) setState(() => _photos.add(photo));
    } catch (e) {
      debugPrint('Chyba focení: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _photos),
                  ),
                  Expanded(
                    child: Text(
                      _photos.isEmpty
                          ? 'Foťte libovolný počet snímků'
                          : '${_photos.length} foto pořízeno',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _photos),
                    child: const Text('Hotovo',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography,
                                color: Colors.white54, size: 64),
                            const SizedBox(height: 16),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => openAppSettings(),
                              icon: const Icon(Icons.settings),
                              label: const Text('Otevřít nastavení'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _isInitialized
                      ? CameraPreview(_controller!)
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white)),
            ),
            if (_photos.isNotEmpty)
              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: _photos.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_photos[i].path),
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isCapturing
                        ? Colors.grey.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.camera_alt,
                          color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
