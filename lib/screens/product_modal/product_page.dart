import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/providers/product_symbol_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/product_modal/product_sort.dart';
import 'package:inzynierka/screens/product_modal/product_symbols.dart';
import 'package:inzynierka/screens/product_modal/product_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
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
    final symbols = useState<List<ProductSymbol>>([]);
    final user = useState<AppUser?>(null);
    final future = useInitFuture(
      () => Future.wait(
        [
          symbolRepository.fetchIds(product.symbols).then((value) => symbols.value = value),
          userRepository.fetchId(product.user).then((value) => user.value = value),
        ],
      ),
    );

    useAutomaticKeepAlive();

    return FutureHandler(
      future: future,
      data: () => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductSort(product: product),
            ConditionalBuilder(
              condition: product.symbols.isNotEmpty,
              ifTrue: () => ProductSymbols(product: product, symbols: symbols.value),
            ),
            ProductUser(user: user.value),
          ],
        ),
      ),
    );
  }
}
