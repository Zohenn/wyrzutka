import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/load_more_list_view.dart';

class ProductList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: GutterColumn(
        gutterSize: 4,
        children: [
          ProductListTitle(productCount: productsCount, title: title),
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

class ProductListTitle extends StatelessWidget {
  const ProductListTitle({
    required this.productCount,
    required this.title,
    Key? key,
  }) : super(key: key);

  final int productCount;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: title,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Text(productCount.toString(), style: const TextStyle(color: AppColors.primaryDarker)),
        ),
      ],
    );
  }
}
