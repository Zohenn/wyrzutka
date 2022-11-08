import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileSortProposalsPage extends HookConsumerWidget {
  const ProfileSortProposalsPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productIds = useState<List<String>>([]);
    final userSortProposals = useState([...user.verifiedSortProposals]);
    final filterProducts = productIds.value.where((element) => user.verifiedSortProposals.contains(element)).toList();
    final products = ref.watch(productsProvider(filterProducts));

    final future = useInitFuture(
          () {
        final newProducts = [...userSortProposals.value.take(10)];
        userSortProposals.value.removeWhere((id) => newProducts.contains(id));
        return ref.read(productRepositoryProvider).fetchIds(newProducts.toList()).then((value) {
          productIds.value = [...productIds.value, ...value.map((product) => product.id)];
          return value;
        });
      },
    );
    final isFetchingMore = useState(false);
    final fetchedAll = useState(false);

    useState(() {});

    return FutureHandler(
      future: future,
      data: () => Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: GutterColumn(
          children: [
            ProfileSortProposalsListTitle(products: products),
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 50.0 &&
                    productIds.value.length >= 10 &&
                    !fetchedAll.value &&
                    !isFetchingMore.value) {
                  (() async {
                    isFetchingMore.value = true;
                    await asyncCall(
                      context,
                          () {
                        final newProducts = [...userSortProposals.value.take(2)];
                        userSortProposals.value.removeWhere((id) => newProducts.contains(id));
                        if (newProducts.isEmpty) {
                          fetchedAll.value = true;
                        }
                        return ref.read(productRepositoryProvider).fetchIds(newProducts.toList()).then((value) {
                          productIds.value = [...productIds.value, ...value.map((product) => product.id)];
                          return value;
                        });
                      },
                    );
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSortProposalsListTitle extends StatelessWidget {
  const ProfileSortProposalsListTitle({
    Key? key,
    required this.products,
  }) : super(key: key);

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            products.length.toString(),
            style: const TextStyle(color: AppColors.primaryDarker),
          ),
        ),
      ],
    );
  }
}
