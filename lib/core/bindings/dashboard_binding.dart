import 'package:get/get.dart';
import 'package:shop_kart/core/controllers/dashboard_controller.dart';
import 'package:shop_kart/features/home/presentation/controllers/product_list_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProductListController>(() => ProductListController());
  }
}

