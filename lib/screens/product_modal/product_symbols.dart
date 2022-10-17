import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/utils/image_error_builder.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.network(
                                symbol.photo,
                                errorBuilder: imageErrorBuilder,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  symbol.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                ConditionalBuilder(
                                  condition: symbol.description != null,
                                  ifTrue: () => Column(
                                    children: [
                                      Text(
                                        symbol.description!,
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
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/no_data.svg', // TODO: Different image
                      width: MediaQuery.of(context).size.width / 4,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Produkt nie posiada oznaczeń',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
