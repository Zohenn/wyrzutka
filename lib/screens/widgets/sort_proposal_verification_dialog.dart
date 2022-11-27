import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class SortProposalVerificationDialog extends HookConsumerWidget {
  const SortProposalVerificationDialog({
    Key? key,
    required this.product,
    required this.sortProposal,
  }) : super(key: key);

  final Product product;
  final Sort sortProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.watch(productServiceProvider);
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
                Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                Text('ID propozycji: ${sortProposal.id}'),
                const SizedBox(height: 24.0),
                Text('Zatwierdzić tę propozycję?', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgressIndicatorButton(
                  isLoading: isDeleting.value,
                  onPressed: () async {
                    isDeleting.value = true;
                    await asyncCall(context, () async {
                      await productService.verifySortProposal(product, sortProposal.id);
                      Navigator.of(context).pop();
                    });
                    isDeleting.value = false;
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: AppColors.positive),
                  child: const Text('Zatwierdź propozycję'),
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('Anuluj'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
