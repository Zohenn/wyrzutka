import 'package:flutter/material.dart';
import 'package:inzynierka/screens/widgets/product_list.dart';

class ProfileListPage extends StatelessWidget {
  const ProfileListPage({
    required this.productsIds,
    required this.title,
    Key? key,
  }) : super(key: key);

  final List<String> productsIds;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return ProductList(
      productsIds: productsIds,
      title: title,
    );
  }
}
