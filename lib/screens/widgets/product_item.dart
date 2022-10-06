import 'package:flutter/material.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/product_modal/product_modal.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/utils/pluralization.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/text_overflow_ellipsis_fix.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:inzynierka/widgets/gutter_row.dart';
import 'package:supercharged/supercharged.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  List<String> get containers {
    final _containers = [...?product.containers];
    if (_containers.length < 4) {
      _containers.addAll(List.generate(4 - _containers.length, (index) => 'empty'));
    }
    return _containers;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        showDefaultBottomSheet(
          context: context,
          builder: (context) => DefaultBottomSheet(
            child: ProductModal(id: product.id),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          child: GutterRow(
            children: [
              ProductPhoto(product: product),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.overflowFix,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    ConditionalBuilder(
                      condition: product.sort != null,
                      ifTrue: () => Text(
                        '${product.sort!.elements.length} ${pluralization('element', product.sort!.elements.length)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      ifFalse: () => Text(
                        'Nieznane',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: ConditionalBuilder(
                  condition: product.sort != null,
                  ifTrue: () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var chunk in containers.chunked(2)) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var container in chunk)
                              Container(
                                decoration: BoxDecoration(
                                  color: ElementContainer.values.byName(container).containerColor,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                ),
                                margin: const EdgeInsets.all(1.0),
                                height: 8,
                                width: 8,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  ifFalse: () => const Icon(Icons.help_outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
