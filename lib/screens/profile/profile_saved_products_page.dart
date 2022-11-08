import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileSavedProductsPage extends HookConsumerWidget {
  const ProfileSavedProductsPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleProductsCount = useState(10);
    final visibleProductIds = useMemoized(
      () => user.savedProducts.take(visibleProductsCount.value).toList(),
      [user.savedProducts, visibleProductsCount.value],
    );
    final products = ref.watch(productsProvider(visibleProductIds));

    final future = useInitFuture(() => ref.read(productRepositoryProvider).fetchIds(visibleProductIds));

    final isFetchingMore = useState(false);
    final fetchedAll = products.length == user.savedProducts.length;

    return FutureHandler(
      future: future,
      data: () => Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: GutterColumn(
          children: [
            ProfileSavedProductsListTitle(products: products),
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 50.0 &&
                    products.length >= 10 &&
                    !fetchedAll &&
                    !isFetchingMore.value) {
                  (() async {
                    isFetchingMore.value = true;
                    await asyncCall(
                      context,
                      () async {
                        final productRepository = ref.read(productRepositoryProvider);
                        final fetchedProducts = await productRepository
                            .fetchIds(user.savedProducts.skip(visibleProductsCount.value).take(10).toList());
                        visibleProductsCount.value += fetchedProducts.length;
                      },
                    );
                    isFetchingMore.value = false;
                  })();
                }
                return false;
              },
              child: Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                  itemCount: isFetchingMore.value ? products.length + 1 : products.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
                    condition: index < products.length,
                    ifTrue: () => ProductItem(product: products[index]),
                    ifFalse: () => const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSavedProductsListTitle extends StatelessWidget {
  const ProfileSavedProductsListTitle({
    Key? key,
    required this.products,
  }) : super(key: key);

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Zapisane produkty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Text(
            products.length.toString(),
            style: const TextStyle(color: AppColors.primaryDarker),
          ),
        ),
      ],
    );
  }
}
