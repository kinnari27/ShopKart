import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_kart/core/utils/debouncer.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';
import 'package:shop_kart/core/widgets/shimmer_box.dart';
import 'package:shop_kart/features/home/presentation/viewmodels/product_list_view_model.dart';
import 'package:shop_kart/features/product/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = ScrollController();
  final _debouncer = Debouncer(const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.extentAfter < 600) {
        ref.read(productListViewModelProvider.notifier).loadNextPage();
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
    final state = ref.watch(productListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ShopKart')),
      body: state.when(
        loading: () => const _HomeSkeleton(),
        error: (error, _) => AppEmptyState(
          title: 'Something went wrong',
          message: error.toString(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(productListViewModelProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search products',
                    ),
                    onChanged: (value) => _debouncer.run(
                      () => ref
                          .read(productListViewModelProvider.notifier)
                          .search(value),
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
                        onSelected: (_) => ref
                            .read(productListViewModelProvider.notifier)
                            .selectCategory(category),
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
        ),
      ),
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
