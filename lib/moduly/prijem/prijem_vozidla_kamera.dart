import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../core/constants.dart';

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
    _nactiStranuSpouste();
  }

  /// Načte osobní předvolbu uživatele (režim pro leváky) ze SharedPreferences.
  Future<void> _nactiStranuSpouste() async {
    final prefs = await SharedPreferences.getInstance();
    final vlevo = prefs.getBool(kPrefKameraSpoustVlevo) ?? false;
    if (mounted && vlevo != _captureOnLeft) {
      setState(() => _captureOnLeft = vlevo);
    }
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

  // Strana spouště v režimu na šířku. false = vpravo (pro praváky),
  // true = vlevo (režim pro leváky). Lze později napojit na nastavení.
  bool _captureOnLeft = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              final sidebar = _buildCaptureBar(vertical: true);
              return Row(
                children: [
                  if (_captureOnLeft) sidebar,
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopBar(),
                        Expanded(child: _buildPreviewArea(orientation)),
                        if (_photos.isNotEmpty) _buildThumbnailStrip(),
                      ],
                    ),
                  ),
                  if (!_captureOnLeft) sidebar,
                ],
              );
            }
            return Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildPreviewArea(orientation)),
                if (_photos.isNotEmpty) _buildThumbnailStrip(),
                _buildCaptureBar(vertical: false),
              ],
            );
          },
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
    );
  }

  Widget _buildPreviewArea(Orientation orientation) {
    if (_error != null) {
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
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Otevřít nastavení'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_isInitialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    // previewSize hlásí kamera vždy v „landscape" (šířka > výška). Poměr stran
    // proto otočíme podle aktuální orientace, jinak je náhled na šířku
    // zobrazený jako úzký portrét.
    final preview = _controller!.value.previewSize!;
    final sensorAspect = preview.width / preview.height;
    final aspect =
        orientation == Orientation.portrait ? 1 / sensorAspect : sensorAspect;
    return Center(
      child: AspectRatio(
        aspectRatio: aspect,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    );
  }

  /// Spoušť. Na výšku jako pruh dole, na šířku jako svislý panel po straně
  /// (palec uživatele) — viz [_captureOnLeft].
  Widget _buildCaptureBar({required bool vertical}) {
    final button = GestureDetector(
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
            : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
      ),
    );

    if (vertical) {
      return Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: button),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: button),
    );
  }
}
