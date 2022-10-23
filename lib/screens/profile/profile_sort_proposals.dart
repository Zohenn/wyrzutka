import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileSortProposals extends HookConsumerWidget {
  const ProfileSortProposals({Key? key, required this.user, required this.onNextPressed,}) : super(key: key);

  final VoidCallback onNextPressed;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final products = user.verifiedSortProposals.take(2).toList();
    final future = useInitFuture<List<Product>>(
      () => productRepository.fetchIds(products),
    );
    final sortProposals = ref.watch(productsProvider(products));

    return GutterColumn(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propozycje segregacji',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Zweryfikowane przez system',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
              child: Text(
                sortProposals.length.toString(),
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        ),
        FutureHandler(
          future: future,
          data: () => ConditionalBuilder(
            condition: sortProposals.isNotEmpty,
            ifTrue: () => Column(
              children: [
                ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: sortProposals.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
                    condition: index < sortProposals.length,
                    ifTrue: () => ProductItem(product: sortProposals[index]),
                  ),
                ),
                ConditionalBuilder(
                  condition: sortProposals.length != user.verifiedSortProposals.length,
                  ifTrue: () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark),
                        ),
                        onPressed: () {},
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
                        child: Icon(Icons.unpublished),
                      ),
                      const SizedBox(width: 16.0),
                      Text('Brak zweryfikowanych propozycji', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onNextPressed,
          child: const Text('Wróć do profilu'),
        ),
      ],
    );
  }
}
