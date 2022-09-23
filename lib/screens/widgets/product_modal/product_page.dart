import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/models/product_symbol.dart';
import 'package:inzynierka/providers/product_symbol_provider.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_sort.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_symbols.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductPage extends HookConsumerWidget {
  const ProductPage({
    Key? key,
    required this.product,
    required this.user,
  }) : super(key: key);

  final Product product;
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolRepository = ref.watch(productSymbolRepositoryProvider);
    final symbols = useRef<List<ProductSymbol>>([]);
    final future = useRef(symbolRepository.fetchIds(product.symbols).then((value) => symbols.value = value));
    useAutomaticKeepAlive();

    return FutureHandler(
      future: future.value,
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
            ConditionalBuilder(
              condition: user != null,
              ifTrue: () => ProductUser(user: user!),
            ),
          ],
        ),
      ),
    );
  }
}
