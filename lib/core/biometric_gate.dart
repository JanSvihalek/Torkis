import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../moduly/main_screen.dart';

class BiometricGate extends StatefulWidget {
  const BiometricGate({super.key});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  bool _authenticated = false;
  bool _checking = true;
  String _biometricLabel = 'Face ID';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometric_enabled') ?? false;

    if (!enabled) {
      if (mounted) setState(() { _authenticated = true; _checking = false; });
      return;
    }

    final auth = LocalAuthentication();
    try {
      final biometrics = await auth.getAvailableBiometrics();
      final hasFace = biometrics.contains(BiometricType.face);
      if (mounted) {
        setState(() {
          _biometricLabel = hasFace ? 'Face ID' : 'biometriku';
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _authenticated = true; _checking = false; });
      return;
    }

    _authenticate();
  }

  Future<void> _authenticate() async {
    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(
        localizedReason: 'Ověřte svou identitu pro vstup do Torkis',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (ok && mounted) setState(() => _authenticated = true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_authenticated) return const MainScreen();
    return _BiometricLockScreen(
      biometricLabel: _biometricLabel,
      onAuthenticate: _authenticate,
    );
  }
}

class _BiometricLockScreen extends StatelessWidget {
  final String biometricLabel;
  final VoidCallback onAuthenticate;

  const _BiometricLockScreen({
    required this.biometricLabel,
    required this.onAuthenticate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/torkis-app-icon-192.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'TORKIS',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ověřte svou identitu',
                style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 56),
              GestureDetector(
                onTap: onAuthenticate,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 44,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Přihlásit přes $biometricLabel',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text(
                  'Přihlásit se heslem',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
