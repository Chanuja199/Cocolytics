import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedDistrict;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── BACKEND — DO NOT TOUCH ──
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your district.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      address: _addressController.text,
      city: _cityController.text,
      district: _selectedDistrict!,
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

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0x993F4A3E), // on-surface-variant/60
        fontSize: 15,
        fontFamily: 'Manrope',
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF006527), size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFEFF6E7), // surface-container-low
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // DEFAULT
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF006527),
          width: 2,
        ), // primary
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFBA1A1A),
          width: 1.5,
        ), // error
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF171D14), // on-surface
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return _buildLabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: Color(0xFF171D14),
          fontSize: 16,
        ),
        decoration: _inputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.state == AuthState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED), // bg-surface
      body: Stack(
        children: [
          // Decorative Background Overlay (Blobs)
          Positioned(
            top: -100,
            right: -100,
            width: 400,
            height: 400,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x337ADB87),
                    Colors.transparent,
                  ], // primary-fixed-dim/20
                  stops: [0.2, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            width: 500,
            height: 500,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x33B6F48A),
                    Colors.transparent,
                  ], // secondary-container/20
                  stops: [0.2, 1.0],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Section
                      Container(
                        width: 96,
                        height: 96,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/icon.jpeg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF006527), // primary
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join Cocolytic to manage your plantation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3F4A3E), // on-surface-variant
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFFFFF,
                          ), // surface-container-lowest
                          borderRadius: BorderRadius.circular(
                            32,
                          ), // rounded-lg conceptually 2rem
                          border: Border.all(
                            color: const Color(0x26BECABB),
                          ), // outline-variant/15
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F171D14), // rgba(23,29,20,0.06)
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildField(
                                label: 'Full Name / සම්පූර්ණ නම',
                                controller: _nameController,
                                hint: 'John Doe',
                                enabled: !isLoading,
                                prefixIcon: Icons.person,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Name is required'
                                    : null,
                              ),

                              _buildField(
                                label: 'Phone Number / දුරකථන අංකය',
                                controller: _phoneController,
                                hint: '07X XXX XXXX',
                                keyboardType: TextInputType.phone,
                                enabled: !isLoading,
                                prefixIcon: Icons.call,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Phone is required'
                                    : null,
                              ),

                              _buildField(
                                label: 'Email Address / විද්‍යුත් තැපෑල',
                                controller: _emailController,
                                hint: 'farmer@example.com',
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                prefixIcon: Icons.mail,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!v.contains('@'))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),

                              _buildField(
                                label: 'Address / ලිපිනය',
                                controller: _addressController,
                                hint: '123 Farm Road',
                                enabled: !isLoading,
                                prefixIcon: Icons.home,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Address is required'
                                    : null,
                              ),

                              // Location Group (City & District)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: 'City / නගරය',
                                      controller: _cityController,
                                      hint: 'City',
                                      enabled: !isLoading,
                                      prefixIcon: Icons.location_city,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'City is required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildLabeledField(
                                      label: 'District / දිස්ත්‍රික්කය',
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedDistrict,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          hintText: 'Select',
                                          prefixIcon: Icons.map,
                                        ),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          color: Color(0xFF171D14),
                                          fontSize: 16,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF3F4A3E),
                                        ),
                                        items: AppConstants.sriLankaDistricts
                                            .map(
                                              (d) => DropdownMenuItem<String>(
                                                value: d,
                                                child: Text(d),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _selectedDistrict = value;
                                                });
                                              },
                                        validator: (v) =>
                                            v == null ? 'Required' : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              _buildField(
                                label: 'Password / මුරපදය',
                                controller: _passwordController,
                                hint: '••••••••',
                                obscureText: _obscurePassword,
                                enabled: !isLoading,
                                prefixIcon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(
                                      0xFF3F4A3E,
                                    ), // on-surface-variant
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password is required';
                                  if (v.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              // Submit Button
                              Container(
                                width: double.infinity,
                                height: 48, // min-h-[48px]
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // rounded-xl
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF006527),
                                      Color(0xFF188038),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Sign Up / ලියාපදිංචි වන්න',
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Navigation Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFF3F4A3E),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: Color(0xFF006527), // primary
                                fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}
