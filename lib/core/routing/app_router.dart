import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_kart/features/auth/presentation/screens/login_screen.dart';
import 'package:shop_kart/features/auth/presentation/screens/register_screen.dart';
import 'package:shop_kart/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:shop_kart/features/cart/presentation/screens/cart_screen.dart';
import 'package:shop_kart/features/cart/presentation/viewmodels/cart_view_model.dart';
import 'package:shop_kart/features/home/presentation/screens/home_screen.dart';
import 'package:shop_kart/features/product/presentation/screens/product_detail_screen.dart';
import 'package:shop_kart/features/profile/presentation/screens/profile_screen.dart';
import 'package:shop_kart/features/wishlist/presentation/screens/wishlist_screen.dart';

import 'package:shop_kart/features/auth/domain/entities/app_user.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(
      authViewModelProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;

  AppUser? get user => _ref.read(authViewModelProvider).value;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: notifier.user == null ? '/login' : '/home',
    redirect: (context, state) {
      final user = notifier.user;
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

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = ['/home', '/cart', '/wishlist', '/profile'].indexOf(location);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (value) =>
            context.go(['/home', '/cart', '/wishlist', '/profile'][value]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: cartCount > 0
                ? Badge.count(
                    count: cartCount,
                    child: const Icon(Icons.shopping_bag_outlined),
                  )
                : const Icon(Icons.shopping_bag_outlined),
            selectedIcon: cartCount > 0
                ? Badge.count(
                    count: cartCount,
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
    );
  }
}
