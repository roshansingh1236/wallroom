// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:shimmer/shimmer.dart';
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

class _FeedScreenState extends ConsumerState<FeedScreen>
    with TickerProviderStateMixin {
  List<String> _categories = ["All"];
  String _selectedCategory = "All";
  late AnimationController _animController;
  late AnimationController _searchAnimController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchActive = false;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  // Pagination state
  List<WallpaperModel> _allWallpapers = [];
  dynamic _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _itemsPerPage = 20;

  // Category keywords mapping
  static const Map<String, List<String>> _categoryKeywords = {
    "Abstract": ["abstract", "liquid", "ripples", "flowing", "artistic"],
    "Nature": [
      "nature",
      "forest",
      "mountain",
      "lake",
      "sunrise",
      "sunset",
      "landscape",
      "pine",
      "desert",
      "sand",
    ],
    "Cyberpunk": [
      "cyberpunk",
      "neon",
      "futuristic",
      "city",
      "street",
      "night",
      "tech",
    ],
    "Anime": ["anime", "cartoon", "kawaii", "manga", "japanese"],
    "Minimal": [
      "minimal",
      "minimalist",
      "simple",
      "clean",
      "white",
      "black",
      "marble",
      "texture",
    ],
    "Space": [
      "space",
      "galaxy",
      "star",
      "planet",
      "cosmic",
      "astronaut",
      "nebula",
      "station",
      "portal",
    ],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && !_isSearchActive) {
        _toggleSearch(true);
      }
    });
  }

  void _setupScrollListener(WidgetRef ref) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreWallpapers(ref);
      }
    });
  }

  Future<void> _loadMoreWallpapers(WidgetRef ref) async {
    if (_isLoadingMore ||
        !_hasMore ||
        _searchQuery.isNotEmpty ||
        _selectedCategory != "All") {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repository = ref.read(wallpapersRepositoryProvider);
      final docs = await repository.getWallpapersPaginatedWithDocs(
        limit: _itemsPerPage,
        lastDocument: _lastDocument,
      );

      if (docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }

      final newWallpapers = docs
          .map((doc) => WallpaperModel.fromDocument(doc))
          .toList();

      setState(() {
        _allWallpapers.addAll(newWallpapers);
        _lastDocument = docs.last;
        _isLoadingMore = false;
        if (docs.length < _itemsPerPage) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshWallpapers(WidgetRef ref) async {
    setState(() {
      _allWallpapers = [];
      _lastDocument = null;
      _hasMore = true;
      _isLoadingMore = false;
    });

    // Force stream to reload
    ref.invalidate(wallpapersStreamProvider);
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchAnimController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _toggleSearch(bool isActive) {
    setState(() {
      _isSearchActive = isActive;
    });

    if (isActive) {
      _searchAnimController.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _searchAnimController.reverse();
      _searchController.clear();
      _searchQuery = '';
      _searchFocusNode.unfocus();
    }
  }

  void _updateCategories(List<WallpaperModel> wallpapers) {
    final Set<String> availableCategories = {"All"};

    // Combine stream wallpapers with stock wallpapers
    final allAvailableWallpapers = [...wallpapers, ...kStockWallpapers];

    // Check each category against all wallpapers
    for (final categoryEntry in _categoryKeywords.entries) {
      final categoryName = categoryEntry.key;
      final keywords = categoryEntry.value;

      // Check if any wallpaper matches this category
      final hasMatch = allAvailableWallpapers.any((wallpaper) {
        final promptLower = wallpaper.prompt.toLowerCase();
        return keywords.any((keyword) => promptLower.contains(keyword));
      });

      if (hasMatch) {
        availableCategories.add(categoryName);
      }
    }

    // Update categories if they changed
    final sortedCategories = [
      "All",
      ...availableCategories.where((c) => c != "All").toList()..sort(),
    ];
    if (_categories.length != sortedCategories.length ||
        !_categories.every((cat) => sortedCategories.contains(cat))) {
      setState(() {
        _categories = sortedCategories;
        // Reset selected category if it's no longer available
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = "All";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallpapersAsync = ref.watch(wallpapersStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF080808)),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Categories
              _buildCategories(),

              // Grid
              Expanded(
                child: wallpapersAsync.when(
                  data: (wallpapers) {
                    // Initialize wallpapers from stream on first load
                    if (_allWallpapers.isEmpty && wallpapers.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _allWallpapers = List.from(wallpapers);
                            if (wallpapers.length >= _itemsPerPage) {
                              _hasMore = true;
                            }
                            // Setup scroll listener after first load
                            _setupScrollListener(ref);
                          });
                          // Update categories based on available wallpapers
                          _updateCategories(wallpapers);
                        }
                      });
                    } else if (_allWallpapers.isEmpty && wallpapers.isEmpty) {
                      // Setup scroll listener even if no data yet
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _setupScrollListener(ref);
                          // Update categories even with empty data (will use stock wallpapers)
                          _updateCategories([]);
                        }
                      });
                    } else if (wallpapers.isNotEmpty) {
                      // Update categories when wallpapers change
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _updateCategories(wallpapers);
                        }
                      });
                    }

                    // Use stream wallpapers if no pagination yet, otherwise use paginated list
                    final baseWallpapers = _allWallpapers.isEmpty
                        ? wallpapers
                        : _allWallpapers;
                    var filteredWallpapers = baseWallpapers;

                    // Filter by category
                    if (_selectedCategory != "All") {
                      filteredWallpapers = filteredWallpapers
                          .where(
                            (w) => w.prompt.toLowerCase().contains(
                              _selectedCategory.toLowerCase(),
                            ),
                          )
                          .toList();
                    }

                    // Filter by search query
                    if (_searchQuery.isNotEmpty) {
                      filteredWallpapers = filteredWallpapers
                          .where(
                            (w) =>
                                w.prompt.toLowerCase().contains(_searchQuery),
                          )
                          .toList();
                    }

                    final bool isShowingStock = filteredWallpapers.isEmpty;
                    if (isShowingStock) {
                      var stockFiltered = kStockWallpapers;

                      // Filter stock wallpapers by category
                      if (_selectedCategory != "All") {
                        stockFiltered = stockFiltered
                            .where(
                              (w) => w.prompt.toLowerCase().contains(
                                _selectedCategory.toLowerCase(),
                              ),
                            )
                            .toList();
                      }

                      // Filter stock wallpapers by search query
                      if (_searchQuery.isNotEmpty) {
                        stockFiltered = stockFiltered
                            .where(
                              (w) =>
                                  w.prompt.toLowerCase().contains(_searchQuery),
                            )
                            .toList();
                      }

                      filteredWallpapers = stockFiltered.isEmpty
                          ? kStockWallpapers
                          : stockFiltered;
                    }

                    if (filteredWallpapers.isEmpty &&
                        (_searchQuery.isNotEmpty ||
                            _selectedCategory != "All")) {
                      // Empty state for search/category filters
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              const Gap(24),
                              Text(
                                "No wallpapers found",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? "Try searching with different keywords"
                                    : "No wallpapers in this category",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                const Gap(24),
                                FakeGlass(
                                  shape: const LiquidRoundedRectangle(
                                    borderRadius: 16.0,
                                  ),
                                  settings: kIOSLiquidGlassSettings,
                                  child: GestureDetector(
                                    onTap: () => _toggleSearch(false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Clear Search",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _refreshWallpapers(ref),
                      color: Colors.purpleAccent,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // Search results header (if searching)
                          if (_searchQuery.isNotEmpty &&
                              filteredWallpapers.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  24,
                                  20,
                                  16,
                                ),
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
                                      "SEARCH RESULTS (${filteredWallpapers.length})",
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

                          // Featured Carousel (only show when not searching)
                          if (_searchQuery.isEmpty)
                            SliverToBoxAdapter(
                              child: _buildFeaturedCarousel(ref),
                            ),

                          if (isShowingStock && _searchQuery.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
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
                                    onTap: () => _showWallpaperDetail(
                                      context,
                                      ref,
                                      wallpaper,
                                    ),
                                  ),
                                );
                              },
                              childCount: filteredWallpapers.length,
                            ),
                          ),

                          // Loading indicator at bottom for lazy loading
                          if (_isLoadingMore &&
                              _searchQuery.isEmpty &&
                              _selectedCategory == "All")
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.purpleAccent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),

                          // End of list indicator
                          if (!_hasMore &&
                              _allWallpapers.isNotEmpty &&
                              _searchQuery.isEmpty &&
                              _selectedCategory == "All")
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    "You've reached the end",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  error: (err, stack) => Center(
                    child: Text(
                      "Error: $err",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  loading: () => _buildShimmerLoader(),
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case "All":
        return Colors.purpleAccent;
      case "Abstract":
        return Colors.blueAccent;
      case "Nature":
        return Colors.greenAccent;
      case "Cyberpunk":
        return Colors.cyanAccent;
      case "Anime":
        return Colors.pinkAccent;
      case "Minimal":
        return Colors.grey.shade400;
      case "Space":
        return Colors.indigoAccent;
      default:
        return Colors.purpleAccent;
    }
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
          final categoryColor = _getCategoryColor(cat);
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 2),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: categoryColor.withValues(alpha: 0.4),
                          offset: const Offset(2, 2),
                        ),
                      ]
                    : [],
              ),
              child: FakeGlass(
                shape: const LiquidRoundedRectangle(borderRadius: 20.0),
                settings: isSelected
                    ? kIOSLiquidGlassSettings.copyWith(
                        glassColor: categoryColor.withValues(alpha: 0.2),
                        thickness: 12,
                      )
                    : kIOSLiquidGlassSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
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

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.15),
      period: const Duration(milliseconds: 1200),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Featured Carousel Shimmer
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const Gap(16),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 320,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Masonry Grid Shimmer
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemBuilder: (context, index) {
                // Create varied heights for masonry effect
                final heights = [
                  200.0,
                  250.0,
                  180.0,
                  220.0,
                  240.0,
                  190.0,
                  230.0,
                  210.0,
                ];
                final height = heights[index % heights.length];

                return Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Main shimmer background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      // Bottom glass overlay shimmer
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showWallpaperDetail(
    BuildContext context,
    WidgetRef ref,
    WallpaperModel wallpaper,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) =>
          _ImmersiveWallpaperDetail(wallpaper: wallpaper, ref: ref),
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
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
                      GestureDetector(
                        onTap: () =>
                            _showFullScreenImage(context, wallpaper.imageUrl),
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
                          child: Hero(
                            tag: wallpaper.id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: CachedNetworkImage(
                                imageUrl: wallpaper.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
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
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
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
                              onPressed: () =>
                                  _handleDownload(context, ref, wallpaper),
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
    );
  }

  Future<void> _handleDownload(
    BuildContext context,
    WidgetRef ref,
    WallpaperModel wallpaper,
  ) async {
    try {
      final adHelper = ref.read(adHelperProvider);
      final didWatchAd = await adHelper.showRewardedAd();

      if (!didWatchAd) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please watch the ad to support the creator."),
            ),
          );
        }
        return;
      }

      await ref
          .read(wallpapersRepositoryProvider)
          .downloadWallpaper(
            wallpaperId: wallpaper.id,
            creatorId: wallpaper.creatorId,
          );

      await Gal.putImage(wallpaper.imageUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wallpaper saved to Gallery!")),
        );
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
                fit: BoxFit.cover,
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
