import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/profile_saved_products_page.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals_page.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({
    Key? key,
    required this.user,
    required this.isMainUser,
    required this.onPageChanged,
  }) : super(key: key);

  final AppUser user;
  final bool isMainUser;
  final void Function(ProfileScreenPages) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          children: [
            ProfileUser(user: user),
            _SavedProductsContainer(savedProducts: user.savedProducts, onPageChanged: onPageChanged),
            _SortProposalsContainer(sortProposals: user.verifiedSortProposals, onPageChanged: onPageChanged),
          ],
        ),
      ),
    );
  }
}

class _SavedProductsContainer extends HookConsumerWidget {
  const _SavedProductsContainer({
    Key? key,
    required this.savedProducts,
    required this.onPageChanged,
  }) : super(key: key);

  final List<String> savedProducts;
  final void Function(ProfileScreenPages) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const numberOfProducts = 2;

    var savedProductsIds = savedProducts.take(numberOfProducts).toList();
    final products = ref.watch(productsProvider(savedProductsIds));

    final future = useInitFuture<List<Product>>(
          () =>
          ref.read(productRepositoryProvider).fetchIds(savedProductsIds).then((value) {
            savedProductsIds = value.map((product) => product.id).toList();
            return value;
          }),
    );

    return GutterColumn(
      crossAxisAlignment: CrossAxisAlignment.end,
      gutterSize: 4,
      children: [
        ProfileSavedProductsListTitle(products: products),
        FutureHandler(
          future: future,
          data: () =>
              ConditionalBuilder(
                condition: products.isNotEmpty,
                ifTrue: () =>
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: products.length,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
                    ),
                ifFalse: () =>
                    Card(
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
                              Text('Brak zapisanych produktów', style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
        ),
        ConditionalBuilder(
          condition: savedProducts.length > numberOfProducts,
          ifTrue: () =>
              TextButton(
                onPressed: () => onPageChanged(ProfileScreenPages.savedProducts),
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

class _SortProposalsContainer extends HookConsumerWidget {
  const _SortProposalsContainer({
    Key? key,
    required this.sortProposals,
    required this.onPageChanged,
  }) : super(key: key);

  final List<String> sortProposals;
  final void Function(ProfileScreenPages) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const numberOfProducts = 2;

    final sortProposalsIds = useState<List<String>>(sortProposals.take(numberOfProducts).toList());
    final products = ref.watch(productsProvider(sortProposalsIds.value));

    final future = useInitFuture<List<Product>>(
          () =>
          ref.read(productRepositoryProvider).fetchIds(sortProposalsIds.value.toList()).then((value) {
            sortProposalsIds.value = value.map((product) => product.id).toList();
            return value;
          }),
    );

    return GutterColumn(
      crossAxisAlignment: CrossAxisAlignment.end,
      gutterSize: 4,
      children: [
        ProfileSortProposalsListTitle(products: products),
        FutureHandler(
          future: future,
          data: () =>
              ConditionalBuilder(
                condition: products.isNotEmpty,
                ifTrue: () =>
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: products.length,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
                    ),
                ifFalse: () =>
                    Card(
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
                              Text('Brak zweryfikowanych propozycji', style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
        ),
        ConditionalBuilder(
          condition: sortProposals.length > numberOfProducts,
          ifTrue: () =>
              TextButton(
                onPressed: () => onPageChanged(ProfileScreenPages.sortProposals),
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
