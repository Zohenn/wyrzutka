import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductList extends HookConsumerWidget {
  const ProductList({
    Key? key,
    required this.products,
    required this.productsCount,
    required this.title,
    required this.onScroll,
    required this.fetchedAll,
  }) : super(key: key);

  final List<Product> products;
  final int productsCount;
  final Widget title;
  final Future Function() onScroll;
  final bool fetchedAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFetchingMore = useState(false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: GutterColumn(
        gutterSize: 4,
        children: [
          ProductListTitle(productCount: productsCount, title: title),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 50.0 &&
                  !fetchedAll &&
                  products.length < productsCount &&
                  !isFetchingMore.value) {
                (() async {
                  isFetchingMore.value = true;
                  await onScroll();
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
    );
  }
}

class ProductListTitle extends HookConsumerWidget {
  const ProductListTitle({
    required this.productCount,
    required this.title,
    Key? key,
  }) : super(key: key);

  final int productCount;
  final Widget title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: title,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Text(
            productCount.toString(),
            style: const TextStyle(color: AppColors.primaryDarker),
          ),
        ),
      ],
    );
  }
}
