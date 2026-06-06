import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_kart/core/network/dio_client.dart';
import 'package:shop_kart/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shop_kart/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_kart/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shop_kart/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_kart/features/product/data/repositories/product_repository_impl.dart';
import 'package:shop_kart/features/product/domain/repositories/product_repository.dart';
import 'package:shop_kart/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:shop_kart/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shop_kart/shared/data/datasources/product_local_data_source.dart';
import 'package:shop_kart/shared/data/datasources/product_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await Hive.initFlutter();
  final preferences = await SharedPreferences.getInstance();
  final productBox = await Hive.openBox<Map>('products');
  final listBox = await Hive.openBox<List>('lists');
  final cartBox = await Hive.openBox<Map>('cart');
  final wishlistBox = await Hive.openBox<Map>('wishlist');

  sl
    ..registerLazySingleton<SharedPreferences>(() => preferences)
    ..registerLazySingleton<Dio>(buildDio)
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(sl()),
    )
    ..registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSource(productBox: productBox, listBox: listBox),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(cartBox))
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(wishlistBox),
    );
}
