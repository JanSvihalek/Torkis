import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/biometric_gate.dart';
import '../core/design_tokens.dart';
import '../core/torkis_ui.dart';
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
    // Auto-trigger jen pokud uživatel biometrii zapnul + credentials existují.
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('biometric_enabled') ?? false)) return;

    final email = await _storage.read(key: 'torkis_email');
    final password = await _storage.read(key: 'torkis_password');
    if (email == null || password == null) return;

    if (!mounted) return;
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
        if (mounted) {
          setState(() => _isLoading = false);
          _showError(
              'Nejprve se přihlaste heslem — Face ID se aktivuje pro příští spuštění.');
        }
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
      backgroundColor: TokColors.ink,
      body: Stack(
        children: [
          // Decorative radial glow behind the logo.
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TokColors.accent.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 24),
                    const Center(
                      child: TorkisMark(
                        size: 76,
                        color: TokColors.paper,
                        inner: TokColors.ink,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'TORKIS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: TokColors.paper,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Digitální příjem vozidel'
                          : 'Zaregistrujte svůj servis',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TokColors.steelSoft,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildDarkField(
                      controller: _emailController,
                      hint: 'E-mail',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildDarkField(
                      controller: _passwordController,
                      hint: 'Heslo',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 12),
                      _buildDarkField(
                        controller: _confirmPasswordController,
                        hint: 'Potvrzení hesla',
                        icon: Icons.lock_reset_rounded,
                        isPassword: true,
                      ),
                    ],
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            minimumSize: const Size(0, 0),
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Zapomněli jste heslo?',
                            style: TextStyle(
                              color: TokColors.steelSoft,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18),
                    const SizedBox(height: 18),

                    TorkisPrimaryButton(
                      label: _isLogin ? 'Přihlásit se' : 'Vytvořit účet',
                      loading: _isLoading,
                      dark: true,
                      onPressed: _isLoading ? null : _submit,
                      trailingIcon: Icons.arrow_forward_rounded,
                    ),
                    if (_isLogin) ...[
                      const SizedBox(height: 12),
                      TorkisSecondaryButton(
                        label: 'Přihlásit přes Face ID',
                        leadingIcon: Icons.face_retouching_natural,
                        dark: true,
                        onPressed:
                            _isLoading ? null : _loginWithBiometric,
                      ),
                    ],
                    const SizedBox(height: 40),

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
                              ? 'Nemáte účet? '
                              : 'Již máte účet? ',
                          style: const TextStyle(
                            color: TokColors.steelSoft,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Zaregistrujte se'
                                  : 'Přihlaste se',
                              style: const TextStyle(
                                color: TokColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildDarkField({
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
      style: const TextStyle(fontSize: 15, color: Colors.white),
      cursorColor: TokColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: TokColors.steelSoft, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: TokColors.accent, size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: TokColors.steelSoft,
                  size: 18,
                ),
                onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TokRadius.md),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TokRadius.md),
          borderSide:
              const BorderSide(color: TokColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
