import 'package:get/get.dart';
import 'package:shop_kart/core/bindings/dashboard_binding.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/routing/auth_middleware.dart';
import 'package:shop_kart/core/routing/dashboard_screen.dart';
import 'package:shop_kart/features/auth/presentation/screens/login_screen.dart';
import 'package:shop_kart/features/auth/presentation/screens/register_screen.dart';
import 'package:shop_kart/features/cart/presentation/screens/cart_screen.dart';
import 'package:shop_kart/features/product/presentation/screens/product_detail_screen.dart';
import 'package:shop_kart/features/profile/presentation/screens/profile_screen.dart';
import 'package:shop_kart/features/wishlist/presentation/screens/wishlist_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () {
        final idParam = Get.parameters['id'];
        final id = idParam != null ? int.parse(idParam) : (Get.arguments as int? ?? 1);
        return ProductDetailScreen(productId: id);
      },
    ),
  ];
}

