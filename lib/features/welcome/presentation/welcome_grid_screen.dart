import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../wallpapers/data/stock_wallpapers.dart';
import '../../wallpapers/data/wallpaper_model.dart';

class WelcomeGridScreen extends StatefulWidget {
  const WelcomeGridScreen({super.key});

  @override
  State<WelcomeGridScreen> createState() => _WelcomeGridScreenState();
}

class _WelcomeGridScreenState extends State<WelcomeGridScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scrollController;
  late ScrollController _scrollViewController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Duplicate wallpapers for infinite scroll
  late List<WallpaperModel> _displayWallpapers;
  // Track failed image URLs to hide them
  final Set<String> _failedImageUrls = {};

  @override
  void initState() {
    super.initState();
    
    // Create duplicated list for infinite scroll (3 copies for seamless loop)
    final baseWallpapers = kStockWallpapers.take(12).toList();
    _displayWallpapers = [...baseWallpapers, ...baseWallpapers, ...baseWallpapers];

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Duration for one full scroll cycle
    );

    _scrollViewController = ScrollController();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();

    // Start infinite scroll animation after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInfiniteScroll();
    });
  }

  void _startInfiniteScroll() {
    if (!mounted || !_scrollViewController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _startInfiniteScroll();
      });
      return;
    }

    final maxScroll = _scrollViewController.position.maxScrollExtent;
    final oneThird = maxScroll / 3;

    // Start at middle section
    _scrollViewController.jumpTo(oneThird);

    // Add listener for smooth scrolling
    _scrollController.addListener(() {
      if (_scrollViewController.hasClients) {
        final currentMax = _scrollViewController.position.maxScrollExtent;
        final scrollValue = _scrollController.value;
        final targetScroll = oneThird + (oneThird * scrollValue);

        if (targetScroll >= currentMax * 0.66) {
          // Reset to beginning of middle section for seamless loop
          _scrollViewController.jumpTo(oneThird);
          _scrollController.reset();
        } else {
          _scrollViewController.jumpTo(targetScroll);
        }
      }
    });

    // Start repeating animation
    _scrollController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: 
       Column(
          children: [
            // Top Grid Section (2/3 of screen)
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Dark Background with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0F0F0F),
                          const Color(0xFF1a1a2e),
                          const Color(0xFF0F0F0F),
                        ],
                      ),
                    ),
                  ),

                  // Animated Blurred Circles
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

                  // Infinite Scrolling Wallpaper Grid
                  _buildInfiniteGrid(),

                  // Bottom Gradient Overlay for Smooth Blend
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.3),
                            const Color(0xFF0F0F0F).withValues(alpha: 0.9),
                            const Color(0xFF0F0F0F),
                          ],
                          stops: const <double>[0.0, 0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Content Section (1/3 of screen)
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0F0F0F).withValues(alpha: 0.3),
                      const Color(0xFF0F0F0F),
                    ],
                  ),
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Name
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "WALL",
                                  style: GoogleFonts.outfit(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.purpleAccent,
                                    letterSpacing: -1,
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
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(12),

                          // Tagline
                          Text(
                            'Every Pixel Tells a Story',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Gap(32),

                          // CTA Button
                          _ModernExploreButton(
                            onPressed: () => context.go('/login'),
                            label: 'Start Explore',
                          ),
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

  Widget _buildInfiniteGrid() {
    // Filter out wallpapers with failed image URLs
    final validWallpapers = _displayWallpapers
        .where((wallpaper) => !_failedImageUrls.contains(wallpaper.thumbnailUrl))
        .toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Prevent manual scrolling but allow programmatic scrolling
        return true;
      },
      child: SingleChildScrollView(
        controller: _scrollViewController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: validWallpapers.isEmpty
              ? const SizedBox.shrink()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: validWallpapers.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(validWallpapers[index], index);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildGridItem(WallpaperModel wallpaper, int index) {
    // Varied tilt angles - more pronounced like in the image
    final tiltAngles = [-0.15, 0.1, -0.08, 0.12, -0.05, 0.15, -0.12, 0.08, -0.1, 0.05, -0.08, 0.12];
    final tiltAngle = tiltAngles[index % tiltAngles.length];

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final delay = (index % 12) * 0.05;
        final animationValue = (_fadeController.value - delay).clamp(0.0, 1.0);
        final opacity = Curves.easeOut.transform(animationValue);
        final scale = 0.7 + (0.3 * Curves.easeOutBack.transform(animationValue));

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: tiltAngle, // Varied tilt angles
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: wallpaper.thumbnailUrl,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.05),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      // Mark this image as failed and trigger rebuild to hide it
                      if (!_failedImageUrls.contains(url)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _failedImageUrls.add(url);
                            });
                          }
                        });
                      }
                      // Return empty container (will be hidden after state update)
                      return const SizedBox.shrink();
                    },
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    httpHeaders: const {
                      'Cache-Control': 'max-age=3600',
                    },
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModernExploreButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _ModernExploreButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_ModernExploreButton> createState() => _ModernExploreButtonState();
}

class _ModernExploreButtonState extends State<_ModernExploreButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
