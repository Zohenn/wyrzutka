import 'package:flutter/material.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_page.dart';
import 'package:inzynierka/screens/widgets/product_modal/variant_page.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/widgets/custom_popup_menu_button.dart';
import 'package:inzynierka/widgets/generic_popup_menu_item.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

class ProductModal extends HookWidget {
  final Product product;
  final AppUser? user;

  const ProductModal({Key? key, required this.product, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final index = useState(0);

    tabController.addListener(() {
      index.value = tabController.index;
    });

    final activeTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        );
    final inactiveTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).cardColor),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProductName(product: product),
        Flexible(
          child: TabBarView(
            controller: tabController,
            children: [
              ProductPage(product: product, user: user),
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
                  // todo: disable if not logged in
                  CustomPopupMenuButton(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  product.id.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
