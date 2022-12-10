import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wyrzutka/screens/product_form/product_form.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_field.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class ProductFormSort extends HookWidget {
  const ProductFormSort({
    Key? key,
    required this.model,
    required this.onElementsChanged,
    required this.onSubmitPressed,
  }) : super(key: key);

  final ProductFormModel model;
  final void Function(SortElements) onElementsChanged;
  final VoidCallback onSubmitPressed;

  SortElements get elements => model.elements;

  bool get isValid => elements.isEmpty || elements.values.every((element) => element.isNotEmpty);

  @override
  Widget build(BuildContext context) {
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
          ConditionalBuilder(
            condition: model.product == null || model.product!.sort != null,
            ifTrue: () => SortElementsField(
              elements: elements,
              onElementsChanged: onElementsChanged,
              required: false,
            ),
            ifFalse: () => const _SortEditUnavailableCard(),
          ),
          const SizedBox(height: 24.0),
          ProgressIndicatorButton(
            onPressed: isValid ? onSubmitPressed : null,
            child: const Center(
              child: Text('Zapisz produkt'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortEditUnavailableCard extends StatelessWidget {
  const _SortEditUnavailableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                radius: 30,
                child: Icon(Icons.block, size: 30),
              ),
              const SizedBox(height: 16.0),
              Text('Brak zatwierdzonej propozycji segregacji', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'Edycja wskazówek dotyczących segregacji będzie dostępna po ich zatwierdzeniu.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
