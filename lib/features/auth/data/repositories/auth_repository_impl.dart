import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/features/auth/domain/entities/app_user.dart';
import 'package:shop_kart/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';

  @override
  AppUser? get currentUser {
    final email = _preferences.getString(_emailKey);
    if (email == null) return null;
    return AppUser(
      name: _preferences.getString(_nameKey) ?? 'ShopKart User',
      email: email,
    );
  }

  @override
  Future<AppUser> login(String email, String password) async {
    _validateEmail(email);
    if (password.length < 6) {
      throw const ValidationException(
        'Password must be at least 6 characters.',
      );
    }
    final user = AppUser(name: email.split('@').first, email: email.trim());
    await _save(user);
    return user;
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    if (name.trim().length < 2) {
      throw const ValidationException('Name is too short.');
    }
    _validateEmail(email);
    if (password.length < 6) {
      throw const ValidationException(
        'Password must be at least 6 characters.',
      );
    }
    final user = AppUser(name: name.trim(), email: email.trim());
    await _save(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _preferences.remove(_nameKey);
    await _preferences.remove(_emailKey);
  }

  Future<void> _save(AppUser user) async {
    await _preferences.setString(_nameKey, user.name);
    await _preferences.setString(_emailKey, user.email);
  }

  void _validateEmail(String email) {
    if (!email.contains('@') || !email.contains('.')) {
      throw const ValidationException('Enter a valid email address.');
    }
  }
}
