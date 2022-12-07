import 'package:flutter/material.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/utils/image_error_builder.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';

enum ProductPhotoType {
  small,
  medium,
}

class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    Key? key,
    required this.product,
    this.type = ProductPhotoType.small,
    this.expandOnTap = false,
    this.baseDecoration = const BoxDecoration(color: Colors.white),
  }) : super(key: key);

  final Product? product;
  final ProductPhotoType type;
  final bool expandOnTap;
  final BoxDecoration baseDecoration;

  @override
  Widget build(BuildContext context) {
    double size;
    BoxDecoration decoration;
    switch (type) {
      case ProductPhotoType.small:
        size = 40;
        decoration = baseDecoration.copyWith(shape: BoxShape.circle);
        break;
      case ProductPhotoType.medium:
        size = 56;
        decoration = baseDecoration.copyWith(borderRadius: const BorderRadius.all(Radius.circular(12)));
        break;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      height: size,
      width: size,
      decoration: decoration,
      child: Center(
        child: ConditionalBuilder(
          condition: product?.photoSmall != null,
          ifTrue: () => Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  product!.photoSmall!,
                  errorBuilder: imageErrorBuilder,
                ),
              ),
              if (expandOnTap && product!.photo != null)
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            clipBehavior: Clip.hardEdge,
                            backgroundColor: Colors.white,
                            child: Image.network(
                              product!.photo!,
                              frameBuilder: (context, child, frame, _) => Align(
                                alignment: Alignment.center,
                                heightFactor: 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ConditionalBuilder(
                                    condition: frame == null,
                                    ifTrue: () => const CircularProgressIndicator(),
                                    ifFalse: () => child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          ifFalse: () => const Icon(Icons.question_mark),
        ),
      ),
    );
  }
}
