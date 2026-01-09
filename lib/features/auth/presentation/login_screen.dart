import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/utils/async_value_ui.dart'; // We'll create this utility
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(authControllerProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF080808),
            ),
          ),
          
          // Accent Blurred Circles for Depth
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  Colors.purpleAccent.withValues(alpha: 0.1),
                  BlendMode.screen,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final fade = CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                  );
                  final slide = CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
                  );

                  return Opacity(
                    opacity: fade.value,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - slide.value)),
                      child: child,
                    ),
                  );
                },
                child: FakeGlass(
                  shape: const LiquidRoundedRectangle(borderRadius: 40.0),
                  settings: kIOSLiquidGlassSettings.copyWith(
                    blur: 30,
                    glassColor: Colors.white.withValues(alpha: 0.05),
                    thickness: 1.5,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Icon
                        Image.asset(
                          'assets/logo/logo.png',
                          height: 250,
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                        
                        // Branded Title
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "WALL",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  letterSpacing: 2,
                                  color: Colors.purpleAccent,
                                  shadows: [
                                    Shadow(
                                      color: Colors.purpleAccent.withValues(alpha: 0.5),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: "ROOM",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        Text(
                          "Create and discover amazing AI wallpapers.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(48),
                        
                        if (state.isLoading)
                          const CircularProgressIndicator(color: Colors.purpleAccent)
                        else ...[
                          _ModernLoginButton(
                            onPressed: () {
                              ref.read(authControllerProvider.notifier).loginAnonymously();
                            },
                            label: "Continue as Guest",
                            icon: Icons.person_outline_rounded,
                          ),
                          const Gap(24),
                          Text(
                            "SIGN IN TO UNLOCK FEATURES",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: Colors.white30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ]
                      ],
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
}

class _ModernLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _ModernLoginButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Gap(12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
