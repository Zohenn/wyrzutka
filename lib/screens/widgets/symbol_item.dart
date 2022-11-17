import 'package:flutter/material.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/utils/image_error_builder.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class SymbolItem extends StatelessWidget {
  const SymbolItem({
    Key? key,
    required this.symbol,
    this.addDeleteButton = false,
    this.onDeletePressed,
  }) : super(key: key);

  final ProductSymbol symbol;
  final bool addDeleteButton;
  final VoidCallback? onDeletePressed;

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
            Expanded(
              child: Column(
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
            ),
            if (addDeleteButton) ...[
              const SizedBox(width: 16),
              IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(Icons.close),
                tooltip: 'Usuń oznaczenie ${symbol.name}',
                style: IconButton.styleFrom(foregroundColor: AppColors.negative),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
