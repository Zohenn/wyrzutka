import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class ProductDeleteDialog extends HookConsumerWidget {
  const ProductDeleteDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final isDeleting = useState(false);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProductPhoto(
                  product: product,
                  type: ProductPhotoType.medium,
                  baseDecoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
                ),
                const SizedBox(height: 8.0),
                Text(product.name),
                const SizedBox(height: 24.0),
                Text('Usunąć ten produkt?', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4.0),
                Text(
                  'Informacji o tym produkcie nie będzie można przywrócić.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('Anuluj'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ProgressIndicatorButton(
                    isLoading: isDeleting.value,
                    onPressed: () async {
                      isDeleting.value = true;
                      await asyncCall(context, () async {
                        await productRepository.delete(product.id);
                        Navigator.of(context).pop(true);
                      });
                      isDeleting.value = false;
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: AppColors.negative),
                    child: const Text('Usuń produkt'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
