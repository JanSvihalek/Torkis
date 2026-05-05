import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const _url = 'https://torkis.cz';

  @override
  void initState() {
    super.initState();
    _launch();
  }

  Future<void> _launch() async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.build_circle, color: Colors.blue, size: 64),
            const SizedBox(height: 24),
            const Text(
              'TORKIS',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _launch,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Otevřít torkis.cz'),
            ),
          ],
        ),
      ),
    );
  }
}
