import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_kart/core/utils/debouncer.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/home/presentation/controllers/product_list_controller.dart';
import 'package:shop_kart/features/product/presentation/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = ScrollController();
  final _debouncer = Debouncer(const Duration(milliseconds: 350));
  late final ProductListController _productListController;

  @override
  void initState() {
    super.initState();
    _productListController = Get.find<ProductListController>();
    _controller.addListener(() {
      if (_controller.position.extentAfter < 600) {
        _productListController.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopKart')),
      body: Obx(() {
        if (_productListController.isLoading.value) {
          return const _HomeSkeleton();
        }

        final error = _productListController.errorMessage.value;
        final data = _productListController.state;

        if (error != null && data.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 54,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _productListController.loadInitialData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _productListController.refreshProducts(),
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search products...',
                    ),
                    onChanged: (value) => _debouncer.run(
                      () => _productListController.search(value),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: data.categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = data.categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: data.selectedCategory == category,
                        onSelected: (_) =>
                            _productListController.selectCategory(category),
                      );
                    },
                  ),
                ),
              ),
              if (data.visibleProducts.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    title: 'No products found',
                    message: 'Try a different search or category.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .68,
                        ),
                    itemCount: data.visibleProducts.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: data.visibleProducts[index]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .68,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => const ShimmerBox(height: 220),
    );
  }
}
