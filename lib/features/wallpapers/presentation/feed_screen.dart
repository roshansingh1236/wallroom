// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/ads/ad_helper.dart';
import '../data/wallpapers_repository.dart';
import '../data/wallpaper_model.dart';
import '../data/stock_wallpapers.dart';
import 'wallpaper_card.dart';
import '../../../core/theme/glass_theme.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  final List<String> _categories = ["All", "Abstract", "Nature", "Cyberpunk", "Anime", "Minimal", "Space"];
  String _selectedCategory = "All";
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final wallpapersAsync = ref.watch(wallpapersStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "WALLROOM",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: FakeGlass(
            shape: const LiquidRoundedRectangle(borderRadius: 0.0),
            settings: kIOSLiquidGlassSettings,
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const Gap(8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF080808),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Categories
              _buildCategories(),
              
              // Grid
              Expanded(
                child: wallpapersAsync.when(
                  data: (wallpapers) {
                    var filteredWallpapers = _selectedCategory == "All" 
                        ? wallpapers 
                        : wallpapers.where((w) => w.prompt.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

                    final bool isShowingStock = filteredWallpapers.isEmpty;
                    if (isShowingStock) {
                      filteredWallpapers = _selectedCategory == "All" 
                          ? kStockWallpapers 
                          : kStockWallpapers.where((w) => w.prompt.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();
                      
                      if (filteredWallpapers.isEmpty) {
                        filteredWallpapers = kStockWallpapers;
                      }
                    }

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Featured Carousel
                        SliverToBoxAdapter(
                          child: _buildFeaturedCarousel(ref),
                        ),

                        if (isShowingStock)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Gap(10),
                                  Text(
                                    "FEATURED COLLECTION",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemBuilder: (context, index) {
                              final wallpaper = filteredWallpapers[index];
                              return _AnimatedGridItem(
                                index: index,
                                controller: _animController,
                                child: WallpaperCard(
                                  wallpaper: wallpaper,
                                  onTap: () => _showWallpaperDetail(context, ref, wallpaper),
                                ),
                              );
                            },
                            childCount: filteredWallpapers.length,
                          ),
                        ),
                      ],
                    );
                  },
                  error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            "TRENDING NOW",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: kStockWallpapers.take(5).length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final wallpaper = kStockWallpapers[index];
              return GestureDetector(
                onTap: () => _showWallpaperDetail(context, ref, wallpaper),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: wallpaper.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Text(
                            wallpaper.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 2),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.4),
                    offset: const Offset(2, 2),
                  )
                ] : [],
              ),
              child: FakeGlass(
                shape: const LiquidRoundedRectangle(borderRadius: 20.0),
                settings: isSelected 
                    ? kIOSLiquidGlassSettings.copyWith(
                        glassColor: Colors.purpleAccent.withValues(alpha: 0.2),
                        thickness: 12,
                      )
                    : kIOSLiquidGlassSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWallpaperDetail(BuildContext context, WidgetRef ref, WallpaperModel wallpaper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => _ImmersiveWallpaperDetail(wallpaper: wallpaper, ref: ref),
    );
  }
}

class _ImmersiveWallpaperDetail extends StatelessWidget {
  final WallpaperModel wallpaper;
  final WidgetRef ref;

  const _ImmersiveWallpaperDetail({required this.wallpaper, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              child: Opacity(
                opacity: 0.2,
                child: CachedNetworkImage(
                  imageUrl: wallpaper.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Content
          Column(
            children: [
              const Gap(50),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview Card
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: wallpaper.id,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: CachedNetworkImage(
                              imageUrl: wallpaper.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(32),
                      
                      // Prompt Section
                      Text(
                        "ARTIST'S PROMPT",
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const Gap(16),
                      FakeGlass(
                        shape: const LiquidRoundedRectangle(borderRadius: 24.0),
                        settings: kIOSLiquidGlassSettings.copyWith(blur: 32),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            wallpaper.prompt,
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const Gap(32),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: _ModernActionButton(
                              onPressed: () => _handleDownload(context, ref, wallpaper),
                              icon: Icons.download_rounded,
                              label: "GET WALLPAPER",
                              primary: true,
                            ),
                          ),
                          const Gap(16),
                          _ModernActionButton(
                            onPressed: () {},
                            icon: Icons.auto_awesome_rounded,
                            label: "",
                            primary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Close Button
          Positioned(
            top: 85,
            right: 30,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, WidgetRef ref, WallpaperModel wallpaper) async {
    try {
      final adHelper = ref.read(adHelperProvider);
      final didWatchAd = await adHelper.showRewardedAd();

      if (!didWatchAd) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please watch the ad to support the creator.")));
        }
        return;
      }

      await ref.read(wallpapersRepositoryProvider).downloadWallpaper(
            wallpaperId: wallpaper.id,
            creatorId: wallpaper.creatorId,
          );

      await Gal.putImage(wallpaper.imageUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallpaper saved to Gallery!")));
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}

class _ModernActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool primary;

  const _ModernActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: primary ? 24 : 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: primary 
              ? const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: primary ? null : Colors.white.withValues(alpha: 0.05),
          border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: primary ? [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (label.isNotEmpty) ...[
              const Gap(12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedGridItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationController controller;

  const _AnimatedGridItem({
    required this.child,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final start = (index % 10) * 0.05;
        final end = start + 0.5;
        final curve = CurvedAnimation(
          parent: controller,
          curve: Interval(
            start > 1.0 ? 1.0 : start,
            end > 1.0 ? 1.0 : end,
            curve: Curves.easeOutQuart,
          ),
        );

        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
