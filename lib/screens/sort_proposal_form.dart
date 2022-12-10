import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_field.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/snackbars.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class SortProposalForm extends HookConsumerWidget {
  const SortProposalForm({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.read(productServiceProvider);

    final elements = useState<SortElements>({});
    final isSaving = useState(false);
    final isValid = useMemoized(
      () => elements.value.isNotEmpty && elements.value.values.every((element) => element.isNotEmpty),
      [elements.value],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Segregacja',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24.0),
          SortElementsField(
            elements: elements.value,
            onElementsChanged: (_elements) => elements.value = _elements,
            required: true,
          ),
          const SizedBox(height: 24.0),
          ProgressIndicatorButton(
            isLoading: isSaving.value,
            onPressed: isValid
                ? () async {
                    isSaving.value = true;
                    await asyncCall(context, () async {
                      await productService.addSortProposal(product, elements.value);

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        successSnackBar(context: context, message: 'Twoja propozycja segregacji została zapisana.'),
                      );
                    });
                    isSaving.value = false;
                  }
                : null,
            child: const Center(
              child: Text('Dodaj propozycję'),
            ),
          ),
        ],
      ),
    );
  }
}
