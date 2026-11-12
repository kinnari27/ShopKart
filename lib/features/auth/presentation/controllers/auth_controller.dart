import 'package:get/get.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/core/routing/app_routes.dart';
import 'package:shop_kart/features/auth/domain/entities/app_user.dart';
import 'package:shop_kart/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_kart/injection/injection.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthRepository _repository;

  AuthController({AuthRepository? repository})
      : _repository = repository ?? sl<AuthRepository>() {
    currentUser.value = _repository.currentUser;
  }

  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isAuthenticated => currentUser.value != null;

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = await _repository.login(email, password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.dashboard);
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      errorMessage.value = message;
      Get.snackbar('Login Failed', message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = await _repository.register(name, email, password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.dashboard);
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      errorMessage.value = message;
      Get.snackbar('Registration Failed', message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
