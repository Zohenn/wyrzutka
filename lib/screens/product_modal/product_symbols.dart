import 'package:flutter/material.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product_symbol/product_symbol.dart';
import 'package:wyrzutka/screens/widgets/symbol_item.dart';
import 'package:wyrzutka/utils/image_error_builder.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductSymbols extends StatelessWidget {
  const ProductSymbols({
    Key? key,
    required this.product,
    required this.symbols,
  }) : super(key: key);

  final Product product;
  final List<ProductSymbol> symbols;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Oznaczenia', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8.0),
        ConditionalBuilder(
          condition: symbols.isNotEmpty,
          ifTrue: () => Column(
            children: [
              GutterColumn(
                children: [
                  for (var symbol in symbols) ...[
                    SymbolItem(symbol: symbol),
                  ],
                  if (symbols.length < product.symbols.length)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: const [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.warning_amber, color: AppColors.warning),
                            ),
                            SizedBox(width: 16.0),
                            Flexible(child: Text('Nie udało się załadować części oznaczeń.')),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          ifFalse: () => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.hide_image_outlined),
                  ),
                  SizedBox(width: 16.0),
                  Text('Produkt nie posiada oznaczeń'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
