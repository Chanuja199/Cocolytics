import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED), // From Tailwind bg-surface
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/coconut-tree.png", fit: BoxFit.cover),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
          // Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Container
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFFBECABB).withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F171D14),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/icon.jpeg",
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Title
                      const Text(
                        "Cocolytic",
                        style: TextStyle(
                          fontFamily: "Plus Jakarta Sans",
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171D14),
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subtitles
                      Column(
                        children: [
                          const Text(
                            "Smart Coconut Disease Detection",
                            style: TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F4A3E),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "ස්මාර්ට් පොල් රෝග හඳුනාගැනීම",
                            style: TextStyle(
                              fontFamily: "Plus Jakarta Sans",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3F4A3E),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                      // Progress Bar
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEE5D6),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF006527), Color(0xFF188038)],
                            ),
                          ),
                        ),
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
