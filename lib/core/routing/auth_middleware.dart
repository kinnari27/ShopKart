import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/features/auth/presentation/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // If AuthController is not yet registered (during startup), let it proceed
    if (!Get.isRegistered<AuthController>()) {
      return null;
    }

    final authController = Get.find<AuthController>();
    final isAuthenticated = authController.isAuthenticated;
    final isAuthRoute = route == AppRoutes.login || route == AppRoutes.register;

    if (!isAuthenticated && !isAuthRoute) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (isAuthenticated && isAuthRoute) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }
    return null;
  }
}

