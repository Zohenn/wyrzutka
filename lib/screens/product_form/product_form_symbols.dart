import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/symbol_item.dart';
import 'package:inzynierka/utils/image_error_builder.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductFormSymbols extends HookConsumerWidget {
  const ProductFormSymbols({
    Key? key,
    required this.model,
    required this.onSymbolsChanged,
    required this.onNextPressed,
  }) : super(key: key);

  final ProductFormModel model;
  final void Function(List<String>) onSymbolsChanged;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = ref.watch(productSymbolsProvider(model.symbols));
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oznaczenia',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Wybierz te symbole, które znajdują się na etykiecie produktu.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ConditionalBuilder(
              condition: model.symbols.isNotEmpty,
              ifTrue: () => GutterColumn(
                children: [
                  for (var symbol in symbols)
                    SymbolItem(
                      key: Key(symbol.id),
                      symbol: symbol,
                      addDeleteButton: true,
                      onDeletePressed: () => onSymbolsChanged([...model.symbols]..remove(symbol.id)),
                    ),
                ],
              ),
              ifFalse: () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          radius: 30,
                          child: Icon(Icons.hide_image_outlined, size: 30),
                        ),
                        const SizedBox(height: 16.0),
                        Text('Nie wybrano oznaczeń', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          'Przejdź dalej, jeżeli opakowanie ich nie zawiera.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final newSymbols = await showDefaultBottomSheet(
                  context: context,
                  builder: (context) => ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ProductSymbolsSheet(symbols: model.symbols),
                  ),
                );

                if (newSymbols != null) {
                  onSymbolsChanged(newSymbols);
                }
              },
              style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    backgroundColor: const MaterialStatePropertyAll(Colors.white),
                    side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
                  ),
              child: const Text('Lista symboli'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onNextPressed,
              child: const Text('Następny krok'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSymbolsSheet extends HookConsumerWidget {
  const ProductSymbolsSheet({
    Key? key,
    required this.symbols,
  }) : super(key: key);

  final List<String> symbols;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productSymbolRepository = ref.watch(productSymbolRepositoryProvider);
    final allSymbols = ref.watch(allProductSymbolsProvider);
    final initFuture = useInitFuture(() => productSymbolRepository.fetchAll());
    final selectedSymbols = useState([...symbols]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: FutureHandler(
        future: initFuture,
        loading: () => const Center(heightFactor: 1.0, child: CircularProgressIndicator()),
        data: () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista oznaczeń',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16.0),
            Flexible(
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 16.0,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (var symbol in allSymbols)
                    _SymbolItem(
                      symbol: symbol,
                      selected: selectedSymbols.value.contains(symbol.id),
                      onToggle: () {
                        if (!selectedSymbols.value.contains(symbol.id)) {
                          selectedSymbols.value = [...selectedSymbols.value, symbol.id];
                        } else {
                          selectedSymbols.value = [...selectedSymbols.value]..remove(symbol.id);
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Zamknij'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedSymbols.value),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDarker,
                  ),
                  child: const Text('Zatwierdź'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SymbolItem extends StatelessWidget {
  const _SymbolItem({
    Key? key,
    required this.symbol,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  final ProductSymbol symbol;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Material(
          color: Colors.white,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? AppColors.primary : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(
                symbol.photo,
                errorBuilder: imageErrorBuilder,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          right: 4,
          child: AnimatedOpacity(
            duration: kThemeChangeDuration,
            opacity: selected ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.all(2.0),
              child: const Icon(Icons.check, size: 12, color: AppColors.primaryDarker),
            ),
          ),
        ),
      ],
    );
  }
}
