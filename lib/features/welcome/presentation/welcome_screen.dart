import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentPage = 0;

  final List<WelcomePage> _pages = [
    WelcomePage(
      title: "Discover\nAmazing Wallpapers",
      description: "Browse through thousands of AI-generated wallpapers created by our community",
      icon: Icons.image_rounded,
      gradient: [Colors.purpleAccent, Colors.deepPurpleAccent],
    ),
    WelcomePage(
      title: "Create Your Own",
      description: "Generate unique wallpapers using AI. Express your creativity and style",
      icon: Icons.auto_awesome_rounded,
      gradient: [Colors.blueAccent, Colors.purpleAccent],
    ),
    WelcomePage(
      title: "Save & Share",
      description: "Save your favorites and share them with friends instantly",
      icon: Icons.favorite_rounded,
      gradient: [Colors.pinkAccent, Colors.deepPurpleAccent],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F0F),
                  Color(0xFF1a1a2e),
                  Color(0xFF0F0F0F),
                ],
              ),
            ),
          ),

          // Animated Background Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Page Content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
                const Gap(40),

                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _ModernButton(
                    onPressed: _nextPage,
                    label: _currentPage == _pages.length - 1
                        ? "Get Started"
                        : "Next",
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ),
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(WelcomePage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_animController.value * 0.2),
                child: Opacity(
                  opacity: _animController.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: page.gradient.map((c) => c.withValues(alpha: 0.3)).toList(),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: page.gradient.first.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const Gap(60),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(24),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? Colors.purpleAccent : Colors.white30,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

class WelcomePage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  WelcomePage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class _ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _ModernButton({
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(12),
            Icon(icon, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

