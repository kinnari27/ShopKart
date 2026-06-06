import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_kart/features/auth/presentation/screens/login_screen.dart';
import 'package:shop_kart/features/auth/presentation/screens/register_screen.dart';
import 'package:shop_kart/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:shop_kart/features/cart/presentation/screens/cart_screen.dart';
import 'package:shop_kart/features/home/presentation/screens/home_screen.dart';
import 'package:shop_kart/features/product/presentation/screens/product_detail_screen.dart';
import 'package:shop_kart/features/profile/presentation/screens/profile_screen.dart';
import 'package:shop_kart/features/wishlist/presentation/screens/wishlist_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authViewModelProvider).value;

  return GoRouter(
    initialLocation: user == null ? '/login' : '/home',
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (user == null && !isAuthRoute) return '/login';
      if (user != null && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = ['/home', '/cart', '/wishlist', '/profile'].indexOf(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (value) =>
            context.go(['/home', '/cart', '/wishlist', '/profile'][value]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
