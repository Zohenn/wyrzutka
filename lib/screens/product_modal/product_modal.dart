import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/product_modal/product_page.dart';
import 'package:inzynierka/screens/product_modal/variant_page.dart';
import 'package:inzynierka/models/product.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/widgets/custom_popup_menu_button.dart';
import 'package:inzynierka/widgets/future_builder.dart';
import 'package:inzynierka/widgets/generic_popup_menu_item.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

class ProductModal extends HookConsumerWidget {
  const ProductModal({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final future = useState<Future?>(null);
    final product = ref.watch(productProvider(id));
    final tabController = useTabController(initialLength: 2);
    final index = useState(0);
    final authUser = ref.watch(authUserProvider);

    useEffect(() {
      future.value = productRepository.fetchId(id);
      return null;
    }, []);

    tabController.addListener(() {
      index.value = tabController.index;
    });

    final activeTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        );
    final inactiveTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).cardColor),
        );

    return FutureHandler(
      future: future.value,
      data: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProductName(product: product!),
          Flexible(
            child: TabBarView(
              controller: tabController,
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
                    AnimatedTheme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme:
                            OutlinedButtonThemeData(style: index.value == 0 ? activeTabStyle : inactiveTabStyle),
                      ),
                      child: Expanded(
                        child: OutlinedButton(
                          onPressed: () => tabController.animateTo(0),
                          child: const Text('Segregacja'),
                        ),
                      ),
                    ),
                    AnimatedTheme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme:
                            OutlinedButtonThemeData(style: index.value == 1 ? activeTabStyle : inactiveTabStyle),
                      ),
                      child: Expanded(
                        child: OutlinedButton(
                          onPressed: () => tabController.animateTo(1),
                          child: const Text('Warianty'),
                        ),
                      ),
                    ),
                    CustomPopupMenuButton(
                      enabled: authUser != null,
                      tooltip: authUser == null ? 'Zaloguj się, aby odblokować dodatkowe funkcje' : null,
                      itemBuilder: (context) => [
                        GenericPopupMenuItem(
                          onTap: () {},
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: const [
                              Icon(Icons.add),
                              SizedBox(width: 16.0),
                              Flexible(child: Text('Zapisz na swojej liście')),
                            ],
                          ),
                        ),
                        GenericPopupMenuItem(
                          onTap: () {},
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: const [
                              Icon(Icons.edit),
                              SizedBox(width: 16.0),
                              Flexible(child: Text('Edytuj informacje')),
                            ],
                          ),
                        ),
                        GenericPopupMenuItem(
                          onTap: () {},
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: const [
                              Icon(Icons.delete),
                              SizedBox(width: 16.0),
                              Flexible(child: Text('Usuń produkt')),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
