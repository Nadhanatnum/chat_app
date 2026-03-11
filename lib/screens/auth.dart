import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

const _deepPurple = Color(0xFF1A0A2E);
const _midPurple = Color(0xFF2D1154);
const _vividPurple = Color(0xFF6C2EB9);
const _lightPurple = Color(0xFFA855F7);
const _glowPurple = Color(0xFFC084FC);
const _cardBg = Color(0xFF1E0C3C);
const _white = Color(0xFFF5F0FF);
const _whiteDim = Color(0x8FF5F0FF);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  String? _selectedImageBase64;
  var _isAuthenticating = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: _midPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      setState(() => _isAuthenticating = true);
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final creds = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final imageData = _selectedImageBase64 ??
            'https://ui-avatars.com/api/?background=2D1154&color=C084FC&size=150&name=${Uri.encodeComponent(_enteredUsername)}';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(creds.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageData,
        });
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Authentication failed.');
      setState(() => _isAuthenticating = false);
    } catch (e) {
      _showSnack('Authentication failed: $e');
      setState(() => _isAuthenticating = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isAuthenticating = true);
    try {
      UserCredential uc;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        uc = await _firebase.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => _isAuthenticating = false);
          return;
        }
        final ga = await googleUser.authentication;
        final cred = GoogleAuthProvider.credential(
            accessToken: ga.accessToken, idToken: ga.idToken);
        uc = await _firebase.signInWithCredential(cred);
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uc.user!.uid)
          .get();
      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uc.user!.uid)
            .set({
          'username': uc.user!.displayName ?? 'Google User',
          'email': uc.user!.email ?? '',
          'image_url': uc.user!.photoURL ??
              'https://ui-avatars.com/api/?background=2D1154&color=C084FC&size=150&name=User',
        });
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Google Sign-In failed.');
      setState(() => _isAuthenticating = false);
    } catch (e) {
      _showSnack('Google Sign-In failed: $e');
      setState(() => _isAuthenticating = false);
    }
  }

  void _signInWithMicrosoft() async {
    setState(() => _isAuthenticating = true);
    try {
      final provider = OAuthProvider('microsoft.com')
        ..addScope('email')
        ..addScope('openid');
      UserCredential uc;
      if (kIsWeb) {
        uc = await _firebase.signInWithPopup(provider);
      } else {
        uc = await _firebase.signInWithProvider(provider);
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uc.user!.uid)
          .get();
      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uc.user!.uid)
            .set({
          'username': uc.user!.displayName ?? 'Microsoft User',
          'email': uc.user!.email ?? '',
          'image_url': uc.user!.photoURL ??
              'https://ui-avatars.com/api/?background=2D1154&color=C084FC&size=150&name=User',
        });
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Microsoft Sign-In failed.');
      setState(() => _isAuthenticating = false);
    } catch (e) {
      _showSnack('Microsoft Sign-In failed: $e');
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0520), _deepPurple, Color(0xFF1A0A2E)],
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _vividPurple.withOpacity(0.35),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _lightPurple.withOpacity(0.25),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(children: [
                const SizedBox(height: 24),
                _buildLogo(),
                const SizedBox(height: 36),
                _buildCard(),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLogo() {
    return Column(children: [
      Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9333EA), Color(0xFF6D28D9)],
          ),
          boxShadow: [
            BoxShadow(
                color: _lightPurple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 2),
            BoxShadow(
                color: _vividPurple.withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: 8),
          ],
        ),
        child: const Icon(Icons.chat_bubble_rounded,
            color: Colors.white, size: 44),
      ),
      const SizedBox(height: 16),
      RichText(
        text: const TextSpan(
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 1.0),
          children: [
            TextSpan(text: 'Flutter', style: TextStyle(color: _white)),
            TextSpan(text: 'Chat', style: TextStyle(color: _glowPurple)),
          ],
        ),
      ),
    ]);
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lightPurple.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!_isLogin) ...[
            UserImagePicker(
              onPickImage: (xfile) async {
                final bytes = await xfile.readAsBytes();
                setState(() {
                  _selectedImageBase64 =
                      'data:image/jpeg;base64,${base64Encode(bytes)}';
                });
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Username',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 4)
                  ? 'At least 4 characters.'
                  : null,
              onSaved: (v) => _enteredUsername = v!,
            ),
            const SizedBox(height: 14),
          ],
          _buildField(
            label: 'Email Address',
            icon: Icons.mail_outline,
            keyboard: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email.' : null,
            onSaved: (v) => _enteredEmail = v!,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: true,
            validator: (v) => (v == null || v.trim().length < 6)
                ? 'At least 6 characters.'
                : null,
            onSaved: (v) => _enteredPassword = v!,
          ),
          const SizedBox(height: 20),
          if (_isAuthenticating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: _glowPurple),
            )
          else ...[
            _buildPrimaryButton(
              label: _isLogin ? 'LOGIN' : 'SIGN UP',
              onTap: _submit,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Create an account' : 'I already have an account',
                style: const TextStyle(color: _glowPurple, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: Divider(color: _lightPurple.withOpacity(0.22))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with',
                      style: TextStyle(
                          fontSize: 11, color: _whiteDim, letterSpacing: 0.8)),
                ),
                Expanded(child: Divider(color: _lightPurple.withOpacity(0.22))),
              ]),
            ),
            const SizedBox(height: 8),
            _buildSocialButton(
              onTap: _signInWithGoogle,
              label: 'Continue with Google',
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                width: 18,
                height: 18,
              ),
            ),
            const SizedBox(height: 10),
            _buildSocialButton(
              onTap: _signInWithMicrosoft,
              label: 'Continue with Microsoft',
              icon: const _MicrosoftIcon(),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboard,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _whiteDim, fontSize: 13),
        prefixIcon: Icon(icon, color: _lightPurple, size: 20),
        filled: true,
        fillColor: _vividPurple.withOpacity(0.10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightPurple.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildPrimaryButton(
      {required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [
            Color(0xFF7C3AED),
            Color(0xFFA855F7),
            Color(0xFFC084FC),
          ]),
          boxShadow: [
            BoxShadow(
                color: _vividPurple.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required String label,
    required Widget icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(label, style: const TextStyle(color: _white, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _lightPurple.withOpacity(0.28)),
          backgroundColor: _vividPurple.withOpacity(0.08),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ── Microsoft icon ────────────────────────────────────────────────────────────
class _MicrosoftIcon extends StatelessWidget {
  const _MicrosoftIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Column(children: [
        Expanded(
            child: Row(children: [
          Expanded(child: Container(color: const Color(0xFFF25022))),
          const SizedBox(width: 1.5),
          Expanded(child: Container(color: const Color(0xFF7FBA00))),
        ])),
        const SizedBox(height: 1.5),
        Expanded(
            child: Row(children: [
          Expanded(child: Container(color: const Color(0xFF00A4EF))),
          const SizedBox(width: 1.5),
          Expanded(child: Container(color: const Color(0xFFFFB900))),
        ])),
      ]),
    );
  }
}
