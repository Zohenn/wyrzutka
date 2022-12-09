import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/repositories/repository.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/screens/profile/widgets/product_list.dart';
import 'package:wyrzutka/screens/profile/widgets/profile_product_list_section.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/widgets/future_handler.dart';

class ProfileAddedProductsPage extends HookConsumerWidget {
  const ProfileAddedProductsPage({
    required this.user,
    Key? key,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.read(productServiceProvider);

    final userProductsCount = useState(0);

    final visibleProducts = useState<List<String>>([]);
    final products = ref.watch(productsProvider(visibleProducts.value));

    final fetchedAll = useState(false);

    final future = useInitFuture(() => Future.wait([
          productService.countProductsAddedByUser(user).then((value) => userProductsCount.value = value),
          productService
              .fetchNextProductsAddedByUser(user: user)
              .then((value) => visibleProducts.value = value.map((product) => product.id).toList()),
        ]).then((value) => fetchedAll.value = products.length >= userProductsCount.value));

    return FutureHandler(
      future: future,
      data: () => ProductList(
        products: products,
        title: 'Dodane produkty',
        productsCount: userProductsCount.value,
        onScroll: () => asyncCall(
          context,
          () async {
            final fetchedProducts = await productService
                .fetchNextProductsAddedByUser(user: user, startAfterDocument: products.last.snapshot!)
                .then((value) {
              visibleProducts.value = [...visibleProducts.value, ...value.map((product) => product.id)];
              return value;
            });
            if (fetchedProducts.length < Repository.batchSize) {
              fetchedAll.value = true;
            }
          },
        ),
        fetchedAll: fetchedAll.value,
      ),
    );
  }
}