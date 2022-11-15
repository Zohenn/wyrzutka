import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/profile/page/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/page/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/page/profile_added_products.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/screens/profile/widgets/profile_product_list_section.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({
    Key? key,
    required this.user,
    required this.onPageChanged,
  }) : super(key: key);

  final AppUser user;
  final void Function(ProfileScreenPages) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.read(productRepositoryProvider);
    final productService = ref.read(productServiceProvider);

    final savedProductsCount = user.savedProducts.length;
    final savedProductsIds = useMemoized(() => user.savedProducts.take(2).toList(), [user.savedProducts]);
    final savedProducts = ref.watch(productsProvider(savedProductsIds));

    final verifiedSortProposalsCount = useState(0);
    final verifiedSortProposalsIds = useState<List<String>>([]);
    final verifiedSortProposalsProducts = ref.watch(productsProvider(verifiedSortProposalsIds.value));

    final userProductsCount = useState(0);
    final userProductsIds = useState<List<String>>([]);
    final userProducts = ref.watch(productsProvider(userProductsIds.value));

    final future = useInitFuture(
          () =>
          Future.wait([
            productService.countVerifiedSortProposals(user).then((value) => verifiedSortProposalsCount.value = value),
            productService.countAddedProducts(user).then((value) => userProductsCount.value = value),

            productRepository.fetchIds(savedProductsIds),
            productService.verifiedSortProposals(user: user, batchSize: 2).then((value) => verifiedSortProposalsIds.value = value.map((product) => product.id).toList()),
            productService.addedProducts(user: user, batchSize: 2).then((value) => userProductsIds.value = value.map((product) => product.id).toList()),
          ]),
    );

    return FutureHandler(
      future: future,
      data: () => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GutterColumn(
            children: [
              ProfileUser(user: user),
              ProfileProductListSection(
                productsCount: savedProductsCount,
                products: savedProducts,
                onPageChanged: onPageChanged,
                destination: ProfileScreenPages.savedProducts,
                title: const SavedProductsTitle(),
                emptyContent: const SavedProductsEmpty(),
              ),
              ProfileProductListSection(
                productsCount: verifiedSortProposalsCount.value,
                products: verifiedSortProposalsProducts,
                onPageChanged: onPageChanged,
                destination: ProfileScreenPages.sortProposals,
                title: const SortProposalsTitle(),
                emptyContent: const SortProposalsEmpty(),
              ),
              ProfileProductListSection(
                productsCount: userProductsCount.value,
                products: userProducts,
                onPageChanged: onPageChanged,
                destination: ProfileScreenPages.addedProducts,
                title: const UserProductsTitle(),
                emptyContent: const UserProductsEmpty(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
