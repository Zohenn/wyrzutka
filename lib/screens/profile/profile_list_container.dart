import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/screens/widgets/product_list.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileListContainer extends HookConsumerWidget {
  const ProfileListContainer({
    Key? key,
    required this.productsIds,
    required this.onPageChanged,
    required this.destination,
    required this.title,
    required this.error,
  }) : super(key: key);

  final List<String> productsIds;
  final void Function(ProfileScreenPages) onPageChanged;
  final ProfileScreenPages destination;
  final Widget title;
  final Widget error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const numberOfProducts = 2;

    var savedProductsIds = productsIds.take(numberOfProducts).toList();
    final products = ref.watch(productsProvider(savedProductsIds));

    final future = useInitFuture<List<Product>>(
      () => ref.read(productRepositoryProvider).fetchIds(savedProductsIds).then(
        (value) {
          savedProductsIds = value.map((product) => product.id).toList();
          return value;
        },
      ),
    );

    return GutterColumn(
      crossAxisAlignment: CrossAxisAlignment.end,
      gutterSize: 4,
      children: [
        ProductListTitle(products: products, title: title),
        FutureHandler(
          future: future,
          data: () => ConditionalBuilder(
            condition: products.isNotEmpty,
            ifTrue: () => ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
              itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
            ),
            ifFalse: () => error,
          ),
        ),
        ConditionalBuilder(
          condition: productsIds.length > numberOfProducts,
          ifTrue: () => TextButton(
            onPressed: () => onPageChanged(destination),
            child: const Text(
              'Pokaż wszystko',
              style: TextStyle(color: AppColors.primaryDarker),
            ),
          ),
        ),
      ],
    );
  }
}
