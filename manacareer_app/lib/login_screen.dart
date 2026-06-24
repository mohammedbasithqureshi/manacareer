import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _successMsg;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) =>
      setState(() { _error = msg; _successMsg = null; _loading = false; });

  void _showSuccess(String msg) =>
      setState(() { _successMsg = msg; _error = null; _loading = false; });

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; _successMsg = null; });
    try {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      await FirebaseAuth.instance.signInWithPopup(provider);
      // Navigation removed - let _ProfileGate handle routing
    } catch (e) {
      _showError('Google sign-in failed. Please try again.');
    }
  }

  Future<void> _emailSignUp() async {
    if (_nameCtrl.text.trim().isEmpty) return _showError('Enter your full name');
    if (_emailCtrl.text.trim().isEmpty) return _showError('Enter your email');
    if (!_emailCtrl.text.contains('@')) return _showError('Enter a valid email');
    if (_passCtrl.text.length < 6) return _showError('Password must be at least 6 characters');
    if (_passCtrl.text != _confirmPassCtrl.text) return _showError('Passwords do not match');

    setState(() { _loading = true; _error = null; _successMsg = null; });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());
      await cred.user?.sendEmailVerification();
      
      // Navigation removed - let _ProfileGate handle routing
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('An account with this email already exists. Sign in instead.');
      } else {
        _showError(e.message ?? 'Sign up failed');
      }
    }
  }

  Future<void> _emailSignIn() async {
    if (_emailCtrl.text.trim().isEmpty) return _showError('Enter your email');
    if (_passCtrl.text.isEmpty) return _showError('Enter your password');

    setState(() { _loading = true; _error = null; _successMsg = null; });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // Navigation removed - let _ProfileGate handle routing
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('No account found with this email. Sign up first.');
      } else if (e.code == 'wrong-password') {
        _showError('Wrong password. Try again or reset it.');
      } else {
        _showError(e.message ?? 'Sign in failed');
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      return _showError('Enter your email above, then tap Forgot password');
    }
    setState(() { _loading = true; _error = null; _successMsg = null; });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailCtrl.text.trim());
      _showSuccess('Reset link sent to ${_emailCtrl.text.trim()}. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Could not send reset email');
    }
  }

  void _switchMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
      _successMsg = null;
      _passCtrl.clear();
      _confirmPassCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: size.width > 480 ? 420 : size.width,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16213B).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: Color(0xFFE2A33B), size: 34),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text('ManaCareer',
                      style: TextStyle(
                          color: Color(0xFF16213B),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _isSignUp ? 'Create your account' : 'Welcome back',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),

                // Google button
                _googleButton(),
                const SizedBox(height: 20),

                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                ]),
                const SizedBox(height: 20),

                // Form
                if (_isSignUp) ...[
                  _label('Full Name'),
                  const SizedBox(height: 6),
                  _field(_nameCtrl, 'e.g. Praneeth Reddy', Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                ],
                _label('Email'),
                const SizedBox(height: 6),
                _field(_emailCtrl, 'your@email.com', Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _label('Password'),
                const SizedBox(height: 6),
                _field(_passCtrl, _isSignUp ? 'Min 6 characters' : 'Your password',
                    Icons.lock_outline_rounded,
                    obscure: _obscurePass,
                    suffix: _eyeBtn(() => setState(() => _obscurePass = !_obscurePass), _obscurePass)),
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  _label('Confirm Password'),
                  const SizedBox(height: 6),
                  _field(_confirmPassCtrl, 'Repeat your password',
                      Icons.lock_outline_rounded,
                      obscure: _obscureConfirm,
                      suffix: _eyeBtn(() => setState(() => _obscureConfirm = !_obscureConfirm), _obscureConfirm)),
                ],
                if (!_isSignUp) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _loading ? null : _forgotPassword,
                      child: const Text('Forgot password?',
                          style: TextStyle(
                              color: Color(0xFFE2A33B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Error / Success
                if (_error != null) _banner(_error!, isError: true),
                if (_successMsg != null) _banner(_successMsg!, isError: false),
                if (_error != null || _successMsg != null) const SizedBox(height: 16),

                // Primary button
                _primaryButton(
                  label: _isSignUp ? 'Create Account' : 'Sign In',
                  onTap: _isSignUp ? _emailSignUp : _emailSignIn,
                ),
                const SizedBox(height: 20),

                // Switch mode
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: _switchMode,
                    child: Text(
                      _isSignUp ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(
                          color: Color(0xFF16213B),
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600));

  Widget _eyeBtn(VoidCallback onTap, bool obscure) => IconButton(
    icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF9CA3AF),
        size: 18),
    onPressed: onTap,
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF16213B), width: 1.5),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return GestureDetector(
      onTap: _loading ? null : _googleSignIn,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
            width: 20,
            height: 20,
            errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 22, color: Color(0xFF4285F4)),
          ),
          const SizedBox(width: 10),
          const Text('Continue with Google',
              style: TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF16213B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF16213B).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3)),
        ),
      ),
    );
  }

  Widget _banner(String msg, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
            size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(msg,
              style: TextStyle(
                  color: isError ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                  fontSize: 12.5,
                  height: 1.4)),
        ),
      ]),
    );
  }
}