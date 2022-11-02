import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/auth_user_service_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/product_modal/product_delete_dialog.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';

class ProductActionsSheet extends HookConsumerWidget {
  const ProductActionsSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    final isSaved = authUser?.savedProducts.contains(product.id) ?? false;
    final isSaving = useState(false);

    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(minLeadingWidth: 0, iconColor: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            iconColor: !isSaved ? AppColors.positive : AppColors.negative,
            leading: Icon(!isSaved ? Icons.add : Icons.remove),
            title: Text(!isSaved ? 'Zapisz na swojej liście' : 'Usuń z listy zapisanych'),
            onTap: () async {
              final authUserService = ref.read(authUserServiceProvider);
              isSaving.value = true;
              await asyncCall(context, () => authUserService.updateSavedProduct(product.id));
              isSaving.value = false;
            },
          ),
          if (authUser?.role == Role.mod || authUser?.role == Role.admin) ...[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edytuj informacje'),
              onTap: () {
                Navigator.of(context).pop();
                showDefaultBottomSheet(
                  context: context,
                  builder: (context) => ProductForm.edit(product: product),
                );
              },
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
