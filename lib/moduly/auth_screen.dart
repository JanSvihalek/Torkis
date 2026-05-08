import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/biometric_gate.dart';
import 'auth_gate.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _storage = FlutterSecureStorage();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initBiometric());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('biometric_enabled') ?? false)) return;

    final auth = LocalAuthentication();
    if (!await auth.canCheckBiometrics) return;

    final email = await _storage.read(key: 'torkis_email');
    final password = await _storage.read(key: 'torkis_password');

    // Biometrie se aktivuje jen pokud jsou uložené přihlašovací údaje.
    // Bez nich uživatel vidí normální formulář — po úspěšném přihlášení
    // heslem se údaje uloží a příště Face ID funguje automaticky.
    if (email == null || password == null) return;

    if (!mounted) return;
    setState(() => _biometricAvailable = true);

    _loginWithBiometric();
  }

  Future<void> _loginWithBiometric() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(
        localizedReason: 'Přihlaste se do Torkis',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!ok || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final email = await _storage.read(key: 'torkis_email');
      final password = await _storage.read(key: 'torkis_password');

      if (email == null || password == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      if (mounted) {
        BiometricGate.justLoggedIn = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } on FirebaseAuthException {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Uložené přihlašovací údaje jsou neplatné. Přihlaste se heslem.');
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Zadejte prosím e-mail i heslo.');
      return;
    }

    if (!_isLogin && password != _confirmPasswordController.text.trim()) {
      _showError('Zadaná hesla se neshodují.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      }

      await _storage.write(key: 'torkis_email', value: email);
      await _storage.write(key: 'torkis_password', value: password);

      if (mounted) {
        BiometricGate.justLoggedIn = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Došlo k chybě při ověřování.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Nesprávný e-mail nebo heslo.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Tento e-mail je již zaregistrován.';
      } else if (e.code == 'weak-password') {
        message = 'Heslo je příliš slabé (min. 6 znaků).';
      } else if (e.code == 'invalid-email') {
        message = 'Neplatný formát e-mailu.';
      }
      _showError(message);
    } catch (e) {
      _showError('Neočekávaná chyba: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Pro obnovu hesla zadejte platný e-mail do horního políčka.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail pro obnovu hesla byl odeslán.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Chyba při odesílání e-mailu pro obnovu.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildFormScreen();

  Widget _buildFormScreen() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(color: const Color(0xFF0B1A2E)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/torkis-app-icon-192.png',
                      width: 192,
                      height: 192,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'TORKIS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLogin
                          ? 'Váš digitální servis v kapse'
                          : 'Zaregistrujte svůj servis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'E-mailová adresa',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Heslo',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Potvrzení hesla',
                        icon: Icons.lock_reset,
                        isPassword: true,
                      ),
                    ],
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          child: const Text(
                            'Zapomněli jste heslo?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Face ID tlačítko (jen v login módu, pokud je dostupné)
                    if (_isLogin && _biometricAvailable) ...[
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _loginWithBiometric,
                        icon: const Icon(Icons.fingerprint, size: 20),
                        label: const Text('Přihlásit přes Face ID'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          side: const BorderSide(
                              color: Colors.blueAccent, width: 1.5),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isLogin ? 'PŘIHLÁSIT SE' : 'VYTVOŘIT ÚČET',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _emailController.clear();
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isLogin
                              ? 'Nemáte ještě účet? '
                              : 'Již máte účet? ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Zaregistrujte se'
                                  : 'Přihlaste se',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }
}
