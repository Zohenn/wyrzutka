import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/screens/product_modal/product_actions_sheet.dart';
import 'package:wyrzutka/screens/product_modal/product_page.dart';
import 'package:wyrzutka/screens/product_modal/variant_page.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wyrzutka/screens/widgets/product_photo.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/default_svg.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/gutter_row.dart';

class ProductModal extends HookConsumerWidget {
  const ProductModal({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.read(productRepositoryProvider);

    final future = useInitFuture(() => productRepository.fetchId(id));
    final product = ref.watch(productProvider(id));
    final authUser = ref.watch(authUserProvider);

    final tabController = useTabController(initialLength: 2);
    final index = useState(0);

    tabController.addListener(() {
      index.value = tabController.index;
    });

    final activeTabStyle = Theme.of(context).elevatedButtonTheme.style!;
    final inactiveTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
      backgroundColor: MaterialStatePropertyAll(Theme.of(context).cardColor),
      side: const MaterialStatePropertyAll(BorderSide.none),
    );

    return FutureHandler(
      future: future,
      data: () => ConditionalBuilder(
        condition: product != null,
        ifTrue: () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProductName(product: product!),
            Flexible(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ProductPage(product: product),
                  VariantPage(product: product),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  child: GutterRow(
                    children: [
                      Expanded(
                        child: AnimatedTheme(
                          data: Theme.of(context).copyWith(
                            elevatedButtonTheme:
                                ElevatedButtonThemeData(style: index.value == 0 ? activeTabStyle : inactiveTabStyle),
                          ),
                          child: ElevatedButton(
                            onPressed: () => tabController.animateTo(0),
                            child: Semantics(
                              selected: index.value == 0,
                              child: const Text('Segregacja'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedTheme(
                          data: Theme.of(context).copyWith(
                            elevatedButtonTheme:
                                ElevatedButtonThemeData(style: index.value == 1 ? activeTabStyle : inactiveTabStyle),
                          ),
                          child: ElevatedButton(
                            onPressed: () => tabController.animateTo(1),
                            child: Semantics(
                              selected: index.value == 1,
                              child: const Text('Warianty'),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: authUser != null
                            ? () async {
                                final shouldClose = await showDefaultBottomSheet<bool>(
                                  context: context,
                                  duration: const Duration(milliseconds: 300),
                                  closeModals: false,
                                  builder: (context) => ProductActionsSheet(product: product),
                                );
                                if (shouldClose == true) {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        tooltip: authUser == null ? 'Wi??cej akcji ??? dost??pne po zalogowaniu' : 'Wi??cej akcji',
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ifFalse: () => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DefaultSvg(assetName: 'assets/images/empty_cart.svg'),
              const SizedBox(height: 24.0),
              Text('Produkt niedost??pny', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  const _ProductName({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ProductPhoto(
              product: product,
              type: ProductPhotoType.medium,
              expandOnTap: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.crop_free, size: Theme.of(context).textTheme.titleSmall!.fontSize! + 4),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          product.id.toString(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
