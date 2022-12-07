import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/repositories/base_repository.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/screens/profile/widgets/product_list.dart';
import 'package:wyrzutka/screens/profile/widgets/profile_product_list_section.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/widgets/future_handler.dart';

class ProfileVerifiedSortProposalsPage extends HookConsumerWidget {
  const ProfileVerifiedSortProposalsPage({
    required this.user,
    Key? key,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.read(productServiceProvider);

    final verifiedSortProposalsCount = useState(0);

    final visibleProducts = useState<List<String>>([]);
    final products = ref.watch(productsProvider(visibleProducts.value));

    final fetchedAll = useState(false);

    final future = useInitFuture(() => Future.wait([
          productService
              .countVerifiedSortProposalsForUser(user)
              .then((value) => verifiedSortProposalsCount.value = value),
          productService
              .fetchNextVerifiedSortProposalsForUser(user: user)
              .then((value) => visibleProducts.value = value.map((product) => product.id).toList()),
        ]).then((value) => fetchedAll.value = products.length >= verifiedSortProposalsCount.value));

    return FutureHandler(
      future: future,
      data: () => ProductList(
        products: products,
        title: 'Propozycje segregacji',
        subtitle: 'Zweryfikowane przez system',
        productsCount: verifiedSortProposalsCount.value,
        onScroll: () => asyncCall(
          context,
          () async {
            final fetchedProducts = await productService
                .fetchNextVerifiedSortProposalsForUser(user: user, startAfterDocument: products.last.snapshot!)
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