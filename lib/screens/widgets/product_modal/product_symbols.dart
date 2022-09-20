import 'package:flutter/material.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductSymbols extends StatelessWidget {
  final Product product;

  const ProductSymbols({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Oznaczenia', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8.0),
        GutterColumn(
          children: [
            for (String symbol in product.symbols) ...[
              ConditionalBuilder(
                condition: getSymbol(symbol) != null,
                ifTrue: () => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          backgroundImage: AssetImage('assets/images/symbols/$symbol.png'),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getSymbol(symbol)!.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ConditionalBuilder(
                              condition: getSymbol(symbol)!.description != null,
                              ifTrue: () => Column(
                                children: [
                                  Text(
                                    getSymbol(symbol)!.description!,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }
}
