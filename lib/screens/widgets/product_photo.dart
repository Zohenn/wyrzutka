import 'package:flutter/material.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 40,
      width: 40,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: ConditionalBuilder(
          condition: product?.photo != null,
          ifTrue: () => Image.asset('assets/images/products/${product!.photo}.png'),
          ifFalse: () => const Icon(Icons.question_mark),
        ),
      ),
    );
  }
}