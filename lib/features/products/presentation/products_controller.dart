import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/products_api.dart';
import '../data/products_repository.dart';
import '../domain/product.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  final CacheManager cache = ref.watch(cacheManagerProvider);
  return ProductsRepository(api: ProductsApi(client), cache: cache);
});

class ProductsListState {
  final List<Product> all;
  final int visibleCount;
  final bool isLoadingMore;

  const ProductsListState({
    required this.all,
    required this.visibleCount,
    required this.isLoadingMore,
  });

  List<Product> get visible {
    final end = visibleCount.clamp(0, all.length);
    return all.take(end).toList(growable: false);
  }

  bool get hasMore => visibleCount < all.length;
}

final productsListControllerProvider =
    AsyncNotifierProvider<ProductsListController, ProductsListState>(
      ProductsListController.new,
    );

class ProductsListController extends AsyncNotifier<ProductsListState> {
  static const int _pageSize = 10;

  @override
  Future<ProductsListState> build() async {
    final repo = ref.read(productsRepositoryProvider);

    final products = await repo.getProductsCachedFirst();

    unawaited(
      repo.revalidateProductsInBackground().then((_) async {
        final updated = await repo.getProductsCachedFirst();
        final current = state.value;
        final visibleCount = current?.visibleCount ?? _pageSize;
        state = AsyncData(
          ProductsListState(
            all: updated,
            visibleCount: visibleCount.clamp(0, updated.length),
            isLoadingMore: false,
          ),
        );
      }),
    );

    return ProductsListState(
      all: products,
      visibleCount: products.length < _pageSize ? products.length : _pageSize,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.isLoadingMore) return;
    if (!current.hasMore) return;

    state = AsyncData(
      ProductsListState(
        all: current.all,
        visibleCount: current.visibleCount,
        isLoadingMore: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));

    final nextCount = (current.visibleCount + _pageSize).clamp(
      0,
      current.all.length,
    );

    state = AsyncData(
      ProductsListState(
        all: current.all,
        visibleCount: nextCount,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final productDetailsProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final repo = ref.read(productsRepositoryProvider);
  final product = await repo.getProductDetailsCachedFirst(id);

  return product;
});
