import 'package:flutter/material.dart';
import 'dart:ui'; // Nutné pro ImageFilter (efekt skla)
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_gate.dart'; // <--- ODKAZ NA NAŠEHO STRÁŽCE

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- NOVÉ: Proměnné pro animaci pozadí ---
  late AnimationController _animController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    
    // Nastavení plynulé animace
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_animController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_animController);

    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- TVOJE PŮVODNÍ LOGIKA (BEZ JAKÉKOLIV ZMĚNY) ---
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
        // PŘIHLÁŠENÍ
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        // REGISTRACE NOVÉHO ÚČTU
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      }

      // PO OBOU AKCÍCH NÁSLEDUJE STEJNÝ KROK: PŘESUNUTÍ NA STRÁŽCE (AuthGate)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. ANIMOVANÉ POZADÍ
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: const [
                      Color(0xFF0F2027), // Velmi tmavě modrá/černá
                      Color(0xFF203A43), // Temně modrá
                      Color(0xFF2C5364), // Lehce světlejší ocelově modrá
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. FORMULÁŘ (Glassmorphism)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.car_repair,
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Torkis',
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
                                ? 'Přihlaste se do svého servisu'
                                : 'Zaregistrujte svůj servis',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
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
                          
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
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
                                text: _isLogin ? 'Nemáte ještě účet? ' : 'Již máte účet? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Zaregistrujte se' : 'Přihlaste se',
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
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }
}