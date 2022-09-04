import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/elements/product_modal.dart';
import 'package:inzynierka/models/sortElement.dart';
import 'package:inzynierka/utils/pluralization.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

List<AppUser> users = [
  const AppUser(email: "1", name: "Wojtek", surname: "Brandeburg"),
  const AppUser(email: "2", name: "Michał", surname: "Marciniak"),
];

AppUser? getUser(String? email) {
  if (email != null) return users.firstWhereOrNull((element) => element.email == email);
  return null;
}

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
                        child: product.photo != ""
                            ? Image.asset("assets/images/${product.photo}.png")
                            : const Icon(Icons.question_mark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        Text(
                          product.sort != null && product.verifiedBy != null
                              ? '${product.sort!.elements.length} ${pluralization('element', product.sort!.elements.length)}'
                              : "Nieznane",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                height: 40,
                width: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: product.containers != null
                      ? Column(
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
                        )
                      : const Icon(Icons.help_outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
