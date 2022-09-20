import 'package:flutter/material.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_sort.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_symbols.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  final AppUser? user;

  const ProductPage({
    Key? key,
    required this.product,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: GutterColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ProductSort(product: product),
          ConditionalBuilder(
            condition: product.symbols.isNotEmpty,
            ifTrue: () => ProductSymbols(product: product),
          ),
          ConditionalBuilder(
            condition: user != null,
            ifTrue: () => ProductUser(user: user!),
          ),
        ],
      ),
    );
  }
}