import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/coconut-tree.png', fit: BoxFit.cover),
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
          // Onboarding Content
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Brand Icon
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0F171D14),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon.jpeg',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Greeting Text
                      const Text(
                        'Welcome to Cocolytic',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171D14),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Cocolytic වෙත සාදරයෙන් පිළිගනිමු',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3F4A3E),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Value Proposition
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Protect your harvest with advanced AI. Early disease detection for healthier coconut plantations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3F4A3E),
                            height: 1.625,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Call to Action
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
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
                          onPressed: () {
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 24),
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
        ],
      ),
    );
  }
}
