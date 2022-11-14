import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/repositories/base_repository.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/profile/product_list.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/future_handler.dart';

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
        title: const UserProductsTitle(),
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
            if (fetchedProducts.length < BaseRepository.batchSize) {
              fetchedAll.value = true;
            }
          },
        ),
        fetchedAll: fetchedAll.value,
      ),
    );
  }
}

class UserProductsTitle extends StatelessWidget {
  const UserProductsTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Dodane produkty', style: Theme.of(context).textTheme.titleMedium);
  }
}

class UserProductsEmpty extends StatelessWidget {
  const UserProductsEmpty({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
              Text(
                'Brak dodanych produktów',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
