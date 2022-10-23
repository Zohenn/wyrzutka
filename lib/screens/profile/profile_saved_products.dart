import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileSavedProducts extends HookConsumerWidget {
  const ProfileSavedProducts({
    Key? key,
    required this.user,
    required this.onNextPressed,
    this.count,
  }) : super(key: key);

  final VoidCallback onNextPressed;
  final AppUser user;
  final int? count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final products = user.savedProducts.take(count != null ? count! : user.savedProducts.length).toList();
    final future = useInitFuture<List<Product>>(
      () => productRepository.fetchIds(products),
    );
    final savedProducts = ref.watch(productsProvider(products));

    return GutterColumn(
      children: [
        Row(
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
                savedProducts.length.toString(),
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        ),
        FutureHandler(
          future: future,
          data: () => ConditionalBuilder(
            condition: savedProducts.isNotEmpty,
            ifTrue: () => Column(
              children: [
                ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: savedProducts.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
                    condition: index < savedProducts.length,
                    ifTrue: () => ProductItem(product: savedProducts[index]),
                  ),
                ),
                ConditionalBuilder(
                  condition: savedProducts.length != user.savedProducts.length,
                  ifTrue: () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark),
                        ),
                        onPressed: onNextPressed,
                        child: const Text('Pokaż wszystko'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ifFalse: () => Card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.star_half),
                      ),
                      const SizedBox(width: 16.0),
                      Text('Brak zapisanych produktów', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
