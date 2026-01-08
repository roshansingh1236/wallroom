import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../data/admin_repository.dart';
import '../../wallpapers/presentation/wallpaper_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingWallpapersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Row(
        children: [
          // Side Nav (Responsive for Web)
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (val) {},
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.approval), label: Text("Moderation")),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text("Users")),
              NavigationRailDestination(icon: Icon(Icons.analytics), label: Text("Stats")),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: pendingAsync.when(
              data: (wallpapers) {
                if (wallpapers.isEmpty) {
                  return const Center(child: Text("All clean! No pending wallpapers."));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: wallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = wallpapers[index];
                    return Column(
                      children: [
                        Expanded(child: WallpaperCard(wallpaper: wallpaper, onTap: (){})),
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton.filled(
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                ref.read(adminRepositoryProvider).rejectWallpaper(wallpaper.id);
                              },
                            ),
                            IconButton.filled(
                              icon: const Icon(Icons.check),
                              style: IconButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {
                                ref.read(adminRepositoryProvider).approveWallpaper(wallpaper.id);
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  },
                );
              },
              error: (e, st) => Center(child: Text("Error: $e")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
