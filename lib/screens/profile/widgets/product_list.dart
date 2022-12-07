import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/screens/profile/widgets/profile_product_list_section.dart';
import 'package:wyrzutka/screens/widgets/product_item.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/load_more_list_view.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    Key? key,
    required this.products,
    required this.productsCount,
    required this.title,
    this.subtitle,
    required this.onScroll,
    required this.fetchedAll,
  }) : super(key: key);

  final List<Product> products;
  final int productsCount;
  final String title;
  final String? subtitle;
  final Future Function() onScroll;
  final bool fetchedAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: GutterColumn(
        gutterSize: 4,
        children: [
          ProfileProductListTitle(title: title, subtitle: subtitle, productsCount: productsCount),
          Expanded(
            child: LoadMoreListView(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
              itemCount: products.length,
              onLoad: onScroll,
              canLoad: !fetchedAll && products.length < productsCount,
              itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileProductListTitle extends StatelessWidget {
  const ProfileProductListTitle({
    Key? key,
    required this.title,
    required this.productsCount,
    this.subtitle,
  }) : super(key: key);

  final String title;
  final int productsCount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              ConditionalBuilder(
                condition: subtitle != null,
                ifTrue: () => Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Text(productsCount.toString(), style: const TextStyle(color: AppColors.primaryDarker)),
        ),
      ],
    );
  }
}