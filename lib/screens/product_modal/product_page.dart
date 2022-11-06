import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/product_modal/product_sort.dart';
import 'package:inzynierka/screens/product_modal/product_symbols.dart';
import 'package:inzynierka/screens/product_modal/product_user.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductPage extends HookConsumerWidget {
  const ProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolRepository = ref.watch(productSymbolRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    final future = useInitFuture(
      () => Future.wait(
        [
          symbolRepository.fetchIds(product.symbols),
          userRepository.fetchIds([
            product.user,
            if (product.sort != null) product.sort!.user,
            ...product.sortProposals.values.map((e) => e.user),
          ]),
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
