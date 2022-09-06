import 'package:flutter/material.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/screens/widgets/product_modal/product_modal.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/utils/pluralization.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:inzynierka/data/static_data.dart';

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
        showMaterialModalBottomSheet(
          context: context,
          builder: (context) => DefaultBottomSheet(
            child: ProductModal(product: product, user: getUser(product.user)),
          ),
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          enableDrag: false,
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                        clipBehavior: Clip.hardEdge,
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: ConditionalBuilder(
                            condition: product.photo != null,
                            ifTrue: () => Image.asset('assets/images/${product.photo}.png'),
                            ifFalse: () => const Icon(Icons.question_mark),
                          ),
                        )),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        Text(
                          product.sort != null && product.verifiedBy != null
                              ? '${product.sort!.elements.length} ${pluralization('element', product.sort!.elements.length)}'
                              : 'Nieznane',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: ConditionalBuilder(
                  condition: product.containers != null,
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
