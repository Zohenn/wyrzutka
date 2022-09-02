import 'package:flutter/material.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/colors.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  const ProductItem({
    Key? key, required this.product
  }) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int index = 0;

  Color getContainerColor(String container) {
    switch(container) {
      case "plastic": return plastic;
      case "paper": return paper;
      case "glass": return glass;
      case "mixed": return mixed;
      case "bio": return bio;
    }
    return gray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      decoration: BoxDecoration(
        color: gray,
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: widget.product.photo != "" ? Image.asset("assets/images/" + widget.product.photo + ".png") : Container(),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(widget.product.containers.isNotEmpty ? widget.product.containers.length.toString() + (widget.product.containers.length == 1 ? " element" : " elementy") : "Nieznane"), // POMOCY
                  ]
                )
              ],
            )
          ),
          Container(
            clipBehavior: Clip.hardEdge,
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle
            ),
            child: Center(
              child: Wrap(
                direction: Axis.vertical,
                spacing: 2,
                children: List.generate(2, (i) => Wrap(
                  direction: Axis.horizontal,
                  spacing: 2,
                  children: List.generate(2, (j) => Builder(
                    builder: (context) {
                      Color color = gray;
                      if(index < widget.product.containers.length) {
                        color = getContainerColor(widget.product.containers.elementAt(i*2+j));
                        index++;
                      }
                      return Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(2))),
                        height: 8,
                        width: 8,
                      );
                    })
                  )
                ))
              ),
            ),
          )
        ],
      ),
    );
  }
}