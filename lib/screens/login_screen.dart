import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first, then tap Forgot Password.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().sendPasswordReset(
        _emailController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFBECABB),
        fontSize: 15,
        fontFamily: 'Manrope',
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF006527), size: 24)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFEFF6E7), // surface-container-low
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7ADB87), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.state == AuthState.loading;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    Widget heroImage = Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/coconut-tree.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: isDesktop
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Color(0x662C3228)],
                    )
                  : LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFFF5FCED),
                        const Color(0xFFF5FCED).withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
            ),
          ),
        ),
        if (isDesktop)
          Positioned(
            bottom: 48,
            left: 48,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icon.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cocolytic',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    color: Color(0x80F5FCED),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    Widget formContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48.0 : 24.0,
        vertical: isDesktop ? 48.0 : 28.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // surface-container-lowest
        borderRadius: isDesktop
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: isDesktop
            ? null
            : [
                const BoxShadow(
                  color: Color(0x14171D14), // rgba(23,29,20,0.08)
                  blurRadius: 48,
                  offset: Offset(0, -16),
                ),
              ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/icon.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cocolytic',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            color: Color(0xFF006527), // primary
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  'Welcome back',
                  textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    color: Color(0xFF171D14), // on-surface
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Sign in to access your plantation insights.\n',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF3F4A3E), // on-surface-variant
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'ඔබේ වගාවේ තොරතුරු වෙත පිවිසෙන්න.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.8,
                          color: Color(0xCC3F4A3E),
                        ),
                      ),
                    ],
                  ),
                  textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text.rich(
                    const TextSpan(
                      text: 'Email ',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF171D14),
                      ),
                      children: [
                        TextSpan(
                          text: '/ විද්‍යුත් තැපෑල',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF3F4A3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF171D14),
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!value.contains('@'))
                      return 'Please enter a valid email';
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'farmer@cocolytic.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ).copyWith(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text.rich(
                        const TextSpan(
                          text: 'Password ',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF171D14),
                          ),
                          children: [
                            TextSpan(
                              text: '/ මුරපදය',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF3F4A3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.go('/forgot-password'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF006527),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF171D14),
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF006527),
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F171D14),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006527), Color(0xFF188038)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign In ',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'පිවිසෙන්න',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 24),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                const Divider(color: Color(0x26BECABB)), // outline-variant/15

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF3F4A3E), // on-surface-variant
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: const Text(
                        'Sign up here',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: Color(0xFF006527), // primary
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED), // bg-surface
      body: isDesktop
          ? Row(
              children: [
                Expanded(flex: 5, child: heroImage),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(child: formContent),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height * 0.28,
                  width: double.infinity,
                  child: heroImage,
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -24), // overlap
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: formContent,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
