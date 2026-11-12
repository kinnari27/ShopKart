import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/bindings/initial_binding.dart';
import 'package:shop_kart/core/routing/app_pages.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/core/theme/app_theme.dart';
import 'package:shop_kart/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shop_kart/features/profile/presentation/controllers/theme_controller.dart';
import 'package:shop_kart/injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ShopKartApp());
}

class ShopKartApp extends StatelessWidget {
  const ShopKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    InitialBinding().dependencies();

    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();

    return Obx(
      () => GetMaterialApp(
        title: 'ShopKart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.themeMode.value,
        initialRoute: authController.isAuthenticated
            ? AppRoutes.dashboard
            : AppRoutes.login,
        getPages: AppPages.routes,
        initialBinding: InitialBinding(),
      ),
    );
  }
}
