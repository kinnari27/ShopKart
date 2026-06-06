import 'package:shop_kart/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String name, String email, String password);
  Future<void> logout();
}
