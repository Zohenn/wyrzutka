import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class VariantPage extends StatelessWidget {
  final Product product;

  const VariantPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: product.variants.isNotEmpty,
      ifTrue: () => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GutterColumn(
          children: [
            for (String variant in product.variants) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        child: ConditionalBuilder(
                          condition: product.photo != null,
                          ifTrue: () => Image.asset("assets/images/${product.photo}.png"),
                          ifFalse: () => const Icon(Icons.question_mark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(variant, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      ifFalse: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/empty_cart.svg', width: MediaQuery.of(context).size.width / 2),
            const SizedBox(height: 24.0),
            Text(
              'Lista wariantów jest pusta',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
