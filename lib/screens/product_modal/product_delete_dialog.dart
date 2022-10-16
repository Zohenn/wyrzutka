import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';

class ProductDeleteDialog extends StatelessWidget {
  const ProductDeleteDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProductPhoto(
                  product: product,
                  type: ProductPhotoType.medium,
                  baseDecoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
                ),
                SizedBox(height: 8.0),
                Text(product.name),
                SizedBox(height: 24.0),
                Text('Usunąć ten produkt?', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 4.0),
                Text(
                  'Informacji o tym produkcie nie będzie można przywrócić.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('Anuluj'),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('Usuń produkt'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: AppColors.negative),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
