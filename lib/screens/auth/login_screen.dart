import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

const _primary = Color(0xFF2E7D32);
const _primaryLight = Color(0xFF4CAF50);
const _primarySurface = Color(0xFFE8F5E9);
const _textDark = Color(0xFF1A1A1A);
const _textLight = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);
const _errorColor = Color(0xFFD32F2F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─── Login Logic ──────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      // Navigate to home and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() => _errorMessage = result['message'] ?? 'Login failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Top green header section ─────────────────────────────────
              _buildHeader(),

              // ── Form section ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error banner
                      if (_errorMessage.isNotEmpty) ...[
                        _buildErrorBanner(),
                        const SizedBox(height: 16),
                      ],

                      // Email field
                      _buildLabel('Email address'),
                      const SizedBox(height: 6),
                      _buildEmailField(),
                      const SizedBox(height: 18),

                      // Password field
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      _buildPasswordField(),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _primaryLight,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      _buildLoginButton(),

                      const SizedBox(height: 20),

                      // Divider
                      _buildDivider(),

                      const SizedBox(height: 20),

                      // Google sign in
                      _buildGoogleButton(),

                      const SizedBox(height: 32),

                      // Sign up link
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      child: Column(
        children: [
          // Logo circle
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🥤', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'NutriBlend',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'FUEL YOUR WELLNESS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primaryLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome back 👋',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to continue to your account',
            style: TextStyle(fontSize: 13, color: _textLight),
          ),
        ],
      ),
    );
  }

  // ─── Error Banner ─────────────────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _errorColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: _errorColor, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = ''),
            child: const Icon(Icons.close, color: _errorColor, size: 16),
          ),
        ],
      ),
    );
  }

  // ─── Label ────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    );
  }

  // ─── Email Field ──────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).requestFocus(_passwordFocus),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _inputDecoration(
        hint: 'you@example.com',
        icon: Icons.mail_outline_rounded,
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Email is required';
        final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!regex.hasMatch(val.trim())) return 'Enter a valid email address';
        return null;
      },
    );
  }

  // ─── Password Field ───────────────────────────────────────────────────────

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _handleLogin,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _inputDecoration(
        hint: 'Enter your password',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: _textLight,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Password is required';
        if (val.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // ─── Login Button ─────────────────────────────────────────────────────────

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        const Expanded(child: Divider(color: _border)),
      ],
    );
  }

  // ─── Google Button ────────────────────────────────────────────────────────

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: _textDark,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEA4335),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('G', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sign Up Link ─────────────────────────────────────────────────────────

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 13, color: _textLight),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Sign up',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Input Decoration ─────────────────────────────────────────────────────

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: _textLight),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
    );
  }
}