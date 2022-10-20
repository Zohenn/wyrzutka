import 'package:flutter/material.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/utils/image_error_builder.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class SymbolItem extends StatelessWidget {
  const SymbolItem({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  final ProductSymbol symbol;

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
