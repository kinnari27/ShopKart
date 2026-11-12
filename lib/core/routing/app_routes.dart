abstract class AppRoutes {
  static const dashboard = '/';
  static const login = '/login';
  static const register = '/register';
  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const profile = '/profile';
  static const productDetail = '/product/:id';

  static String product(int id) => '/product/$id';
}

