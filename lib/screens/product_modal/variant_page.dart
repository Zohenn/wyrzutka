import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/screens/product_modal/product_modal.dart';
import 'package:wyrzutka/screens/widgets/product_photo.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/utils/text_overflow_ellipsis_fix.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';

class VariantPage extends HookConsumerWidget {
  const VariantPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);

    final future = useInitFuture<List<Product>>(
      () => productRepository.fetchIds(product.variants),
    );
    final variants = ref.watch(productsProvider(product.variants));

    useAutomaticKeepAlive();

    return ConditionalBuilder(
      condition: product.variants.isNotEmpty,
      ifTrue: () => FutureHandler(
        future: future,
        data: () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: GutterColumn(
            children: [
              for (var variant in variants) ...[
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      showDefaultBottomSheet(context: context, builder: (context) => ProductModal(id: variant.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ProductPhoto(product: variant),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Tooltip(
                              message: variant.name,
                              child: Text(
                                variant.name.overflowFix,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
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
