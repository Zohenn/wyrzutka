import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/product_modal/product_delete_dialog.dart';

class ProductActionsSheet extends HookConsumerWidget {
  const ProductActionsSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(minLeadingWidth: 0, iconColor: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            iconColor: AppColors.positive,
            leading: Icon(Icons.add),
            title: Text('Zapisz na swojej liście'),
            onTap: () {},
          ),
          if (authUser?.role == Role.mod || authUser?.role == Role.admin) ...[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edytuj informacje'),
              onTap: () {},
            ),
            ListTile(
              iconColor: AppColors.negative,
              leading: Icon(Icons.delete),
              title: Text('Usuń produkt'),
              onTap: () async {
                final wasDeleted =
                    await showDialog(context: context, builder: (context) => ProductDeleteDialog(product: product));
                if (wasDeleted == true) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
