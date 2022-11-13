import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/screens/profile/product_list.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileProductListSection extends HookConsumerWidget {
  const ProfileProductListSection({
    Key? key,
    required this.products,
    required this.productsCount,
    required this.onPageChanged,
    required this.destination,
    required this.title,
    required this.emptyContent,
  }) : super(key: key);

  final List<Product> products;
  final int productsCount;
  final void Function(ProfileScreenPages) onPageChanged;
  final ProfileScreenPages destination;
  final Widget title;
  final Widget emptyContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GutterColumn(
      crossAxisAlignment: CrossAxisAlignment.end,
      gutterSize: 4,
      children: [
        ProductListTitle(productCount: productsCount, title: title),
        ConditionalBuilder(
          condition: products.isNotEmpty,
          ifTrue: () => GutterColumn(
            children: [
              for(var product in products)
                ProductItem(product: product),
            ],
          ),
          ifFalse: () => emptyContent,
        ),
        ConditionalBuilder(
          condition: products.length < productsCount,
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
