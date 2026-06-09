import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'biometric_signature.dart';
import 'biometric_signature_pad.dart';

/// Celoobrazovkové podepisování. Plátno vyplní celou plochu, takže během
/// podpisu nelze nikam scrollovat ani s obrazovkou hýbat – dlaň položená na
/// tabletu nezpůsobí posun pod prstem.
///
/// Pracuje přímo s předaným [BiometricSignatureController] (kvůli zachování
/// biometrie i opravy velikosti plátna). Při otevření si vezme snímek stavu;
/// pokud uživatel zavře bez potvrzení, stav se vrátí přesně do podoby před
/// otevřením. Vrací `true`, když uživatel podpis potvrdil tlačítkem „Hotovo".
class SignatureCaptureScreen extends StatefulWidget {
  final BiometricSignatureController controller;
  final bool isDark;

  const SignatureCaptureScreen({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static Future<bool> open(
    BuildContext context,
    BiometricSignatureController controller,
    bool isDark,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SignatureCaptureScreen(
          controller: controller,
          isDark: isDark,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  late final SignatureSnapshot _snapshot;
  late final int _snapshotPoints;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.controller.snapshot();
    _snapshotPoints = _pointCount(_snapshot.strokes);
  }

  int _pointCount(List<SignatureStroke> strokes) =>
      strokes.fold(0, (sum, s) => sum + s.points.length);

  /// Změnil uživatel oproti stavu při otevření?
  bool get _dirty =>
      _pointCount(widget.controller.visibleStrokes) != _snapshotPoints;

  Future<void> _zavrit() async {
    final l10n = AppLocalizations.of(context);
    if (_dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.prijemPodpisZahoditTitul),
          content: Text(l10n.prijemPodpisZahoditPomoc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.prijemPodpisZavrit),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.prijemPodpisZahodit),
            ),
          ],
        ),
      );
      if (discard != true) return;
    }
    widget.controller.restore(_snapshot);
    if (mounted) Navigator.of(context).pop(false);
  }

  void _hotovo() => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bg = widget.isDark ? const Color(0xFF0B1A2E) : Colors.grey[100]!;
    final iconColor = widget.isDark ? Colors.white70 : Colors.grey[700];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _zavrit();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(l10n, bg, iconColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildPad(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n, Color bg, Color? iconColor) {
    return Container(
      height: 56,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.prijemPodpisZavrit,
            color: iconColor,
            onPressed: _zavrit,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              l10n.prijemPodpisNahled,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (_, __) => TextButton.icon(
              onPressed: widget.controller.isEmpty
                  ? null
                  : () => widget.controller.clear(),
              icon: const Icon(Icons.clear, size: 18, color: Colors.red),
              label: Text(l10n.prijemPodpisSmazat,
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (_, __) => ElevatedButton.icon(
                onPressed: widget.controller.isEmpty ? null : _hotovo,
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.prijemPodpisHotovo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPad() {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              // Vodicí čára a výzva — zobrazí se jen u prázdného plátna.
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (_, __) => widget.controller.isEmpty
                      ? _buildGuide(context)
                      : const SizedBox.shrink(),
                ),
              ),
              BiometricSignaturePad(
                controller: widget.controller,
                height: constraints.maxHeight,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGuide(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, 0.55),
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Container(height: 1.5, color: Colors.grey[300]),
            ),
          ),
          Text(
            l10n.prijemPodpisHint,
            style: TextStyle(color: Colors.grey[350], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
