import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/screens/profile/widgets/product_list.dart';
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
    this.subtitle,
    required this.emptyContentTitle,
    required this.emptyContentIcon,
  }) : super(key: key);

  final List<Product> products;
  final int productsCount;
  final void Function(ProfileScreenPages) onPageChanged;
  final ProfileScreenPages destination;
  final String title;
  final String? subtitle;
  final String emptyContentTitle;
  final IconData emptyContentIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GutterColumn(
      crossAxisAlignment: CrossAxisAlignment.end,
      gutterSize: 4,
      children: [
        ProfileProductListTitle(title: title, subtitle: subtitle, productsCount: productsCount),
        ConditionalBuilder(
          condition: products.isNotEmpty,
          ifTrue: () => GutterColumn(
            children: [
              for (var product in products) ProductItem(product: product),
            ],
          ),
          ifFalse: () => Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      child: Icon(emptyContentIcon),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      emptyContentTitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConditionalBuilder(
          condition: products.length < productsCount,
          ifTrue: () => TextButton(
            onPressed: () => onPageChanged(destination),
            child: Text(
              'Pokaż wszystko',
              style: const TextStyle(color: AppColors.primaryDarker),
              semanticsLabel: 'Pokaż wszystko $title',
            ),
          ),
        ),
      ],
    );
  }
}