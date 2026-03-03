import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/models/leisure.dart';
import 'package:interview/features/products/presentation/products_controller.dart';
import 'package:interview/screens/product_detail_screen.dart';
import 'package:interview/screens/widgets/dashboard_header.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/features/profile/presentation/profile_controller.dart';
import 'widgets/leisure_card.dart';
import 'widgets/section_header.dart';
import 'widgets/diamond_membership_card.dart';
import 'package:interview/utils/page_transitions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int index = 0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 300) {
      ref.read(productsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsListControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final authUser = ref.watch(authControllerProvider).value?.user;
    final points = profileAsync.value?.points ?? authUser?.points ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Profile + Icons Row
            DashboardHeader(showCart: true),
            DiamondMembershipCard(points: points),

            const SectionHeader(title: "Leisures"),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: productsState.when(
                  data: (data) {
                    final items = data.visible
                        .map(
                          (p) => Leisure(
                            title: p.name,
                            price:
                                p.minPrice == null
                                    ? ''
                                    : MoneyFormatter.ngn(p.minPrice),
                            image: p.primaryImageUrl,
                          ),
                        )
                        .toList(growable: false);

                    final itemCount =
                        data.hasMore ? items.length + 1 : items.length;

                    if (items.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(productsListControllerProvider.notifier)
                            .retry();
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: itemCount,
                        itemBuilder: (_, i) {
                          if (data.hasMore && i == items.length) {
                            return Center(
                              child: SpinKitFadingCircle(
                                size: 30,
                                color: AppColors.whiteColor,
                              ),
                            );
                          }

                          final leisure = items[i];
                          final product = data.visible[i];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                            child: LeisureCard(leisure: leisure),
                          );
                        },
                      ),
                    );
                  },
                  loading:
                      () => Center(
                        child: SpinKitFadingCircle(
                          size: 30,
                          color: AppColors.whiteColor,
                        ),
                      ),
                  error: (err, _) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Failed to load products'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(productsListControllerProvider.notifier)
                                  .retry();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
