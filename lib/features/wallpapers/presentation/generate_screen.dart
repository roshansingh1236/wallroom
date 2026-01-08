import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/ads/ad_helper.dart';
import '../data/wallpapers_repository.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> with SingleTickerProviderStateMixin {
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
    "Minimalist landscape of a lone tree on a flotating island, pastel colors, dreamlike atmosphere"
  ];

  final List<String> _styles = [
    "Realistic",
    "Anime",
    "Cyberpunk",
    "Oil Painting",
    "Pixel Art",
    "Fantasy",
    "3D Render"
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

  Future<void> _handleGenerate() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a prompt"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.redAccent,
        ),
      );
      _focusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // return; // Allow generation to proceed
      }

      // 2. Call Cloud Function
      await ref.read(wallpapersRepositoryProvider).generateWallpaper(
            prompt: _promptController.text,
            aspectRatio: _aspectRatio.value,
            style: _style.value,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Generation Started! Check the Feed soon."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _promptController.clear();
        FocusScope.of(context).unfocus();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Create Wallpaper", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1C1C1E),
              Color(0xFF110E1B),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          Colors.blueAccent.withOpacity(0.15)
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
                        )
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
                          child: const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 24),
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
                      const Text("THE PROMPT",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          )),
                      GestureDetector(
                        onTap: _surpriseMe,
                        child: Row(
                          children: [
                            Icon(Icons.casino, color: Colors.purpleAccent.withOpacity(0.8), size: 16),
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
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "E.g., A cyberpunk city in neon rain, realistic, 8k...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
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
                  child: const Text("ART STYLE",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      )),
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
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF353535) : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.purpleAccent : Colors.white10,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.purpleAccent.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  style,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                  child: const Text("ASPECT RATIO",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      )),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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

  const _AnimatedEntry({required this.child, required this.delay, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final start = delay / 1000;
        final end = start + 0.4;
        final curve = CurvedAnimation(
          parent: controller,
          curve: Interval(start > 1.0 ? 1.0 : start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutCubic),
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
          color: isSelected ? const Color(0xFF353535) : Colors.white.withOpacity(0.05),
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
                  )
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
