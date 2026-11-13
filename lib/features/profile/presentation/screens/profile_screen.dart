import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shop_kart/features/profile/presentation/controllers/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = authController.currentUser.value;
        final themeMode = themeController.themeMode.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(user?.name ?? 'Guest'),
              subtitle: Text(user?.email ?? ''),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('My Orders & Tracking'),
                subtitle: const Text('View history and track ongoing deliveries'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(AppRoutes.orders),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) =>
                  themeController.setMode(value.first),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => authController.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      }),
    );
  }
}
