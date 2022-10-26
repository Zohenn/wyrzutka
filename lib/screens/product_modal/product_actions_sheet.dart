import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/product_modal/product_delete_dialog.dart';
import 'package:inzynierka/utils/async_call.dart';

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
              // todo: extract to some service
              final userRepository = ref.watch(userRepositoryProvider);
              isSaving.value = true;
              await asyncCall(context, () async {
                if (!isSaved) {
                  final user = await userRepository.saveProduct(authUser!, product.id);
                  ref.read(authUserProvider.notifier).state = user;
                } else {
                  final user = await userRepository.removeProduct(authUser!, product.id);
                  ref.read(authUserProvider.notifier).state = user;
                }
              });
              isSaving.value = false;
            },
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
