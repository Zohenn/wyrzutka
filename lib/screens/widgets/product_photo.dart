import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

enum ProductPhotoType {
  small,
  medium,
}

const _baseDecoration = BoxDecoration(color: Colors.white);

class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    Key? key,
    required this.product,
    this.type = ProductPhotoType.small,
    this.expandOnTap = false,
  }) : super(key: key);

  final Product? product;
  final ProductPhotoType type;
  final bool expandOnTap;

  @override
  Widget build(BuildContext context) {
    double size;
    BoxDecoration decoration;
    switch (type) {
      case ProductPhotoType.small:
        size = 40;
        decoration = _baseDecoration.copyWith(shape: BoxShape.circle);
        break;
      case ProductPhotoType.medium:
        size = 56;
        decoration = _baseDecoration.copyWith(borderRadius: const BorderRadius.all(Radius.circular(12)));
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
                padding: const EdgeInsets.all(2.0),
                child: Image.network(
                  product!.photoSmall!,
                  errorBuilder: (context, error, stackTrace) => const Tooltip(
                    message: 'Zdjęcie niedostępne',
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.negative,
                    ),
                  ),
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
                              loadingBuilder: (context, child, progress) => Align(
                                alignment: Alignment.center,
                                heightFactor: 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ConditionalBuilder(
                                    condition: progress != null,
                                    ifTrue: () => CircularProgressIndicator(
                                      value: progress!.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                    ),
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
