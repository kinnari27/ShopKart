import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/features/auth/domain/entities/app_user.dart';
import 'package:shop_kart/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_kart/injection/injection.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => sl());

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AsyncValue<AppUser?>>(AuthViewModel.new);

class AuthViewModel extends Notifier<AsyncValue<AppUser?>> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AsyncValue<AppUser?> build() => AsyncData(_repository.currentUser);

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.register(name, email, password),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }
}
