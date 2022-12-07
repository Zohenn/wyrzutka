import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/repositories/product_symbol_repository.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:wyrzutka/screens/widgets/product_sort.dart';
import 'package:wyrzutka/screens/product_modal/product_symbols.dart';
import 'package:wyrzutka/screens/product_modal/product_user.dart';
import 'package:wyrzutka/services/user_service.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';

class ProductPage extends HookConsumerWidget {
  const ProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolRepository = ref.watch(productSymbolRepositoryProvider);
    final userService = ref.watch(userServiceProvider);

    final future = useInitFuture(
      () => Future.wait(
        [
          symbolRepository.fetchIds(product.symbols),
          userService.fetchUsersForProduct(product),
        ],
      ),
    );
    final symbols = ref.watch(productSymbolsProvider(product.symbols));
    final user = ref.watch(userProvider(product.user));

    useAutomaticKeepAlive();

    return FutureHandler(
      future: future,
      data: () => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductSort(product: product),
            ProductSymbols(product: product, symbols: symbols),
            ProductUser(user: user),
          ],
        ),
      ),
    );
  }
}
