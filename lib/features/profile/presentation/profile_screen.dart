import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/user_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
             ref.read(authControllerProvider.notifier).logout();
            },
          )
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Not logged in"));
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 50,
                     backgroundColor: Colors.deepPurple,
                     child: Text(user.displayName[0], style: const TextStyle(fontSize: 40, color: Colors.white)),
                   ),
                   const Gap(16),
                   Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
                   const Gap(8),
                   Text("Coins: ${user.coins}", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber)),
                   const Gap(24),
                   const Divider(),
                   const ListTile(
                     leading: Icon(Icons.image),
                     title: Text("My Wallpapers"),
                     trailing: Icon(Icons.chevron_right),
                   ),
                   const ListTile(
                     leading: Icon(Icons.monetization_on),
                     title: Text("Redeem Coins"),
                     trailing: Icon(Icons.chevron_right),
                   ),
                   const Spacer(),
                   if (user.isAnonymous)
                     const Card(
                       child: Padding(
                         padding: EdgeInsets.all(8.0),
                         child: Text("Link your email to save progress permanently.", textAlign: TextAlign.center),
                       ),
                     ),
                ],
              ),
            ),
          );
        },
        error: (err, stack) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
