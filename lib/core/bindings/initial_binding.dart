import 'package:get/get.dart';
import 'package:shop_kart/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shop_kart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:shop_kart/features/profile/presentation/controllers/theme_controller.dart';
import 'package:shop_kart/features/wishlist/presentation/controllers/wishlist_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<WishlistController>(WishlistController(), permanent: true);
  }
}

