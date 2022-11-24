import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/auth_user_service.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/product_modal/product_delete_dialog.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProductActionsSheet extends HookConsumerWidget {
  const ProductActionsSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserService = ref.read(authUserServiceProvider);
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
            leading: ConditionalBuilder(
              condition: isSaving.value == false,
              ifTrue: () => Icon(!isSaved ? Icons.add : Icons.remove),
              ifFalse: () => SizedBox.square(
                dimension: 24,
                child: SpinKitDoubleBounce(
                  size: 18,
                  color: !isSaved ? AppColors.positive : AppColors.negative,
                ),
              ),
            ),
            title: Text(!isSaved ? 'Zapisz na swojej liście' : 'Usuń z listy zapisanych'),
            onTap: isSaving.value == false
                ? () async {
                    isSaving.value = true;
                    await asyncCall(context, () => authUserService.updateSavedProduct(product.id));
                    isSaving.value = false;
                  }
                : null,
          ),
          if (authUser?.role == Role.mod || authUser?.role == Role.admin) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edytuj informacje'),
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
              leading: const Icon(Icons.delete),
              title: const Text('Usuń produkt'),
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
