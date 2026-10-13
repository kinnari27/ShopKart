import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_kart/core/errors/app_exception.dart';
import 'package:shop_kart/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  late SharedPreferences preferences;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = AuthRepositoryImpl(preferences);
  });

  group('login', () {
    test('should succeed with valid email and password >= 6 chars', () async {
      final user = await repository.login('john.doe@example.com', '123456');

      expect(user.email, 'john.doe@example.com');
      expect(user.name, 'john.doe');
      expect(repository.currentUser?.email, 'john.doe@example.com');
    });

    test('should throw ValidationException on invalid email', () async {
      expect(
        () => repository.login('invalidemail', '123456'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ValidationException on short password', () async {
      expect(
        () => repository.login('test@example.com', '123'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('register', () {
    test('should succeed with valid name, email, and password', () async {
      final user = await repository.register('Jane', 'jane@example.com', 'secret');

      expect(user.name, 'Jane');
      expect(user.email, 'jane@example.com');
      expect(repository.currentUser?.name, 'Jane');
    });

    test('should throw ValidationException if name is too short', () async {
      expect(
        () => repository.register('A', 'jane@example.com', 'secret'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('logout and currentUser', () {
    test('currentUser should return null when not logged in', () {
      expect(repository.currentUser, isNull);
    });

    test('logout should clear session from preferences', () async {
      await repository.login('user@test.com', 'password123');
      expect(repository.currentUser, isNotNull);

      await repository.logout();

      expect(repository.currentUser, isNull);
    });
  });
}
