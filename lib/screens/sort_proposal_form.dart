import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/screens/widgets/sort_elements_input.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class SortProposalForm extends HookConsumerWidget {
  const SortProposalForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = useState<SortElements>({});
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
          SortElementsInput(
            elements: elements.value,
            onElementsChanged: (_elements) => elements.value = _elements,
            required: true,
          ),
          const SizedBox(height: 24.0),
          ProgressIndicatorButton(
            onPressed: isValid ? (){} : null,
            child: const Center(
              child: Text('Dodaj propozycję'),
            ),
          ),
        ],
      ),
    );
  }
}
