import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../core/ads/ad_helper.dart';
import '../../../core/theme/glass_theme.dart';
import '../data/wallpapers_repository.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen>
    with SingleTickerProviderStateMixin {
  final _promptController = TextEditingController();
  final _aspectRatio = ValueNotifier<String>("9:16");
  final _style = ValueNotifier<String>("Realistic");
  final _focusNode = FocusNode();
  bool _isLoading = false;
  late AnimationController _animController;

  final List<String> _creativePrompts = [
    "A cyberpunk city with neon rain reflecting on wet pavement, 8k resolution, cinematic lighting",
    "A serene japanese garden in autumn with falling maple leaves, unreal engine 5 render",
    "Futuristic space station orbiting a purple gas giant, sci-fi concept art",
    "Portrait of a warrior cat in golden armor, oil painting style, detailed fur texture",
    "Minimalist landscape of a lone tree on a flotating island, pastel colors, dreamlike atmosphere",
  ];

  final List<String> _styles = [
    "Realistic",
    "Anime",
    "Cyberpunk",
    "Oil Painting",
    "Pixel Art",
    "Fantasy",
    "3D Render",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _aspectRatio.dispose();
    _style.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _surpriseMe() {
    final random = Random();
    final prompt = _creativePrompts[random.nextInt(_creativePrompts.length)];
    _promptController.text = prompt;
    _animController.forward(from: 0.5); // Slight replay of animation for effect
  }

  void _showGeneratedWallpaperDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> wallpaperData,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (dialogContext) =>
          _GeneratedWallpaperDialog(wallpaperData: wallpaperData, ref: ref),
    );
  }

  Future<void> _handleGenerate() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a prompt"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      _focusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Show Ad
      final adHelper = ref.read(adHelperProvider);
      final didWatchAd = await adHelper.showRewardedAd();

      if (!didWatchAd) {
        // setState(() => _isLoading = false); // Don't stop loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Ad skipped. Generating anyway..."),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // return; // Allow generation to proceed
      }

      // 2. Call Cloud Function
      final result = await ref
          .read(wallpapersRepositoryProvider)
          .generateWallpaper(
            prompt: _promptController.text,
            aspectRatio: _aspectRatio.value,
            style: _style.value,
          );

      if (mounted && result != null && result['success'] == true) {
        // Show dialog with generated wallpaper
        _showGeneratedWallpaperDialog(context, ref, result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Generation completed! Check the Feed soon."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1C1C1E), Color(0xFF110E1B)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Inspiration
                _AnimatedEntry(
                  controller: _animController,
                  delay: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purpleAccent.withOpacity(0.15),
                          Colors.blueAccent.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.purpleAccent,
                            size: 24,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Unleash Creativity",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                "Describe your dream. AI will paint it.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(32),

                // Prompt Section Title
                _AnimatedEntry(
                  controller: _animController,
                  delay: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "THE PROMPT",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: _surpriseMe,
                        child: Row(
                          children: [
                            Icon(
                              Icons.casino,
                              color: Colors.purpleAccent.withOpacity(0.8),
                              size: 16,
                            ),
                            const Gap(6),
                            Text(
                              "Surprise Me",
                              style: TextStyle(
                                color: Colors.purpleAccent.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),

                // Prompt Input
                _AnimatedEntry(
                  controller: _animController,
                  delay: 200,
                  child: TextField(
                    controller: _promptController,
                    focusNode: _focusNode,
                    maxLines: 5,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "E.g., A cyberpunk city in neon rain, realistic, 8k...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.purpleAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

                const Gap(32),

                // Style Selector
                _AnimatedEntry(
                  controller: _animController,
                  delay: 250,
                  child: const Text(
                    "ART STYLE",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Gap(12),
                _AnimatedEntry(
                  controller: _animController,
                  delay: 280,
                  child: ValueListenableBuilder<String>(
                    valueListenable: _style,
                    builder: (context, currentStyle, child) {
                      return SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _styles.length,
                          separatorBuilder: (_, __) => const Gap(10),
                          itemBuilder: (context, index) {
                            final style = _styles[index];
                            final isSelected = style == currentStyle;
                            return GestureDetector(
                              onTap: () => _style.value = style,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF353535)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.purpleAccent
                                        : Colors.white10,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.purpleAccent
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  style,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const Gap(32),

                // Aspect Ratio Selector
                _AnimatedEntry(
                  controller: _animController,
                  delay: 300,
                  child: const Text(
                    "ASPECT RATIO",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Gap(12),
                _AnimatedEntry(
                  controller: _animController,
                  delay: 400,
                  child: ValueListenableBuilder<String>(
                    valueListenable: _aspectRatio,
                    builder: (context, value, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: _AspectRatioCard(
                              label: "Mobile",
                              ratio: "9:16",
                              icon: Icons.smartphone,
                              groupValue: value,
                              onChanged: (v) => _aspectRatio.value = v,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _AspectRatioCard(
                              label: "Square",
                              ratio: "1:1",
                              icon: Icons.crop_square,
                              groupValue: value,
                              onChanged: (v) => _aspectRatio.value = v,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _AspectRatioCard(
                              label: "Desktop",
                              ratio: "16:9",
                              icon: Icons.monitor,
                              groupValue: value,
                              onChanged: (v) => _aspectRatio.value = v,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Gap(48),

                // Generate Button
                _AnimatedEntry(
                  controller: _animController,
                  delay: 500,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shadowColor: Colors.purpleAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.movie_filter_outlined, size: 22),
                                Gap(10),
                                Text(
                                  "Watch Ad & Generate",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final Widget child;
  final int delay;
  final AnimationController controller;

  const _AnimatedEntry({
    required this.child,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final start = delay / 1000;
        final end = start + 0.4;
        final curve = CurvedAnimation(
          parent: controller,
          curve: Interval(
            start > 1.0 ? 1.0 : start,
            end > 1.0 ? 1.0 : end,
            curve: Curves.easeOutCubic,
          ),
        );

        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AspectRatioCard extends StatelessWidget {
  final String label;
  final String ratio;
  final IconData icon;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _AspectRatioCard({
    required this.label,
    required this.ratio,
    required this.icon,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = ratio == groupValue;
    return GestureDetector(
      onTap: () => onChanged(ratio),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF353535)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.purpleAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 26,
            ),
            const Gap(10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const Gap(4),
            Text(
              ratio,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedWallpaperDialog extends StatefulWidget {
  final Map<String, dynamic> wallpaperData;
  final WidgetRef ref;

  const _GeneratedWallpaperDialog({
    required this.wallpaperData,
    required this.ref,
  });

  @override
  State<_GeneratedWallpaperDialog> createState() =>
      _GeneratedWallpaperDialogState();
}

class _GeneratedWallpaperDialogState extends State<_GeneratedWallpaperDialog> {
  bool _isDownloading = false;
  bool _isSubmitting = false;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);

    try {
      final imageUrl = widget.wallpaperData['imageUrl'] as String;
      await Gal.putImage(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Wallpaper saved to Gallery!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error downloading: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      // The wallpaper is already in Firestore from the generation function
      // This is just a confirmation/notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Wallpaper submitted to community!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(imageUrl: imageUrl),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.wallpaperData['imageUrl'] as String? ?? '';
    final prompt = widget.wallpaperData['prompt'] as String? ?? '';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, imageUrl),
                          child: Container(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.purpleAccent,
                                              ),
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.white24,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(32),

                        // Prompt Section
                        Text(
                          "PROMPT",
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const Gap(16),
                        FakeGlass(
                          shape: const LiquidRoundedRectangle(
                            borderRadius: 24.0,
                          ),
                          settings: kIOSLiquidGlassSettings.copyWith(blur: 32),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              prompt.isNotEmpty
                                  ? prompt
                                  : "AI Generated Wallpaper",
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
                        Column(
                          children: [
                            // Download Button
                            _ModernActionButton(
                              onPressed: _isDownloading
                                  ? null
                                  : _handleDownload,
                              icon: Icons.download_rounded,
                              label: _isDownloading ? "" : "GET WALLPAPER",
                              primary: true,
                              isLoading: _isDownloading,
                            ),
                            const Gap(12),
                            // Submit Button
                            _ModernActionButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              icon: Icons.upload_rounded,
                              label: _isSubmitting
                                  ? ""
                                  : "SUBMIT TO COMMUNITY AND EARN",
                              primary: false,
                              isLoading: _isSubmitting,
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
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool primary;
  final bool isLoading;

  const _ModernActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 18,
          horizontal: primary ? 24 : 18,
        ),
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
          border: primary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
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

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Image
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                progressIndicatorBuilder: (context, url, progress) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purpleAccent,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white24,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
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
