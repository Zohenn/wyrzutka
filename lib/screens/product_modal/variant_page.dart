import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class VariantPage extends HookConsumerWidget {
  const VariantPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final variants = useState<List<Product>>([]);
    final future = useState<Future?>(null);

    useEffect(() {
      productRepository.fetchIds(product.variants).then((value) => variants.value = value);
      return null;
    }, []);

    useAutomaticKeepAlive();

    return ConditionalBuilder(
      condition: product.variants.isNotEmpty,
      ifTrue: () => FutureHandler(
        future: future.value,
        data: () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: GutterColumn(
            children: [
              // todo: make these clickable, I suppose?
              for (var variant in variants.value) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ProductPhoto(product: variant),
                        const SizedBox(width: 16),
                        Text(variant.name, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ifFalse: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/empty_cart.svg', width: MediaQuery.of(context).size.width / 2),
            const SizedBox(height: 24.0),
            Text(
              'Lista wariantów jest pusta',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}