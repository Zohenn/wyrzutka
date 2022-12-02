import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/profile/widgets/product_list.dart';
import 'package:inzynierka/screens/profile/widgets/profile_product_list_section.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/future_handler.dart';

class ProfileSavedProductsPage extends HookConsumerWidget {
  const ProfileSavedProductsPage({
    required this.user,
    Key? key,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.read(productRepositoryProvider);

    final savedProductCount = user.savedProducts.length;

    final visibleProductsCount = useState(10);
    final visibleProductIds = user.savedProducts.take(visibleProductsCount.value).toList();
    final products = ref.watch(productsProvider(visibleProductIds));

    final future = useInitFuture(() => ref.read(productRepositoryProvider).fetchIds(visibleProductIds));

    final fetchedAll = products.length >= user.savedProducts.length;

    return FutureHandler(
      future: future,
      data: () => ProductList(
        products: products,
        title: 'Zapisane produkty',
        productsCount: savedProductCount,
        onScroll: () => asyncCall(
          context,
          () async {
            final fetchedProducts =
                await productRepository.fetchIds(user.savedProducts.skip(visibleProductsCount.value).take(10).toList());
            visibleProductsCount.value += fetchedProducts.length;
          },
        ),
        fetchedAll: fetchedAll,
      ),
    );
  }
}