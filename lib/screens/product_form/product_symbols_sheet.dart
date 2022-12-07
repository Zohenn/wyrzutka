import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/product_symbol/product_symbol.dart';
import 'package:wyrzutka/repositories/product_symbol_repository.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/utils/image_error_builder.dart';
import 'package:wyrzutka/widgets/future_handler.dart';

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
    return Semantics(
      container: true,
      selected: selected,
      label: symbol.name,
      child: ExcludeSemantics(
        child: Stack(
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
                    semanticLabel: symbol.name,
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
        ),
      ),
    );
  }
}