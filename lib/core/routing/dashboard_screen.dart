import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/controllers/dashboard_controller.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/features/cart/presentation/screens/cart_screen.dart';
import 'package:shop_kart/features/home/presentation/screens/home_screen.dart';
import 'package:shop_kart/features/profile/presentation/screens/profile_screen.dart';
import 'package:shop_kart/features/wishlist/presentation/screens/wishlist_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final cartController = Get.find<CartController>();

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: dashboardController.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: dashboardController.currentIndex.value,
          onDestinationSelected: dashboardController.changeTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: cartController.itemCount > 0
                  ? Badge.count(
                      count: cartController.itemCount,
                      child: const Icon(Icons.shopping_bag_outlined),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              selectedIcon: cartController.itemCount > 0
                  ? Badge.count(
                      count: cartController.itemCount,
                      child: const Icon(Icons.shopping_bag),
                    )
                  : const Icon(Icons.shopping_bag),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

