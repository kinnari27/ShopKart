import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/core/routing/app_router.dart';
import 'package:shop_kart/core/theme/app_theme.dart';
import 'package:shop_kart/features/profile/presentation/viewmodels/theme_view_model.dart';
import 'package:shop_kart/injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ProviderScope(child: ShopKartApp()));
}

class ShopKartApp extends ConsumerWidget {
  const ShopKartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title: 'ShopKart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
