import 'package:flutter/material.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/utils/pluralization.dart';
import 'package:supercharged/supercharged.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  Color getContainerColor(BuildContext context, String container) {
    switch (container) {
      case "plastic":
        return AppColors.plastic;
      case "paper":
        return AppColors.paper;
      case "glass":
        return AppColors.glass;
      case "mixed":
        return AppColors.mixed;
      case "bio":
        return AppColors.bio;
    }
    return Theme.of(context).cardColor;
  }

  List<String> get containers {
    final _containers = [...product.containers];
    if(_containers.length < 4){
      _containers.addAll(List.generate(4 - _containers.length, (index) => ''));
    }
    return _containers;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          : Container(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Text(
                        product.containers.isNotEmpty
                            ? '${product.containers.length} ${pluralization('element', product.containers.length)}'
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var chunk in containers.chunked(2)) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var container in chunk)
                            Container(
                              decoration: BoxDecoration(
                                color: getContainerColor(context, container),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
