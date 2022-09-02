import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/elements/product_item.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final searchController = TextEditingController();
  final productsList = const {
    Product(name: "Woda niegazowana", photo: "woda", symbols: [], containers: ["plastic"]),
    Product(name: "Napój energetyczny", photo: "", symbols: [], containers: []),
    Product(name: "Chusteczki", photo: "", symbols: [], containers: ["paper", "mixed"]),
    Product(name: "Papier toaletowy", photo: "", symbols: [], containers: []),
    Product(name: "Frugo", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
  };

  void onSearchPress() {
    print("Search pressed");
  }
  void onFilterPress() {
    print("Filter pressed");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
      Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Wyszukaj",
                      prefixIcon: IconButton(onPressed: onSearchPress, icon: Icon(Icons.search, color: Colors.black)),
                      suffixIcon: IconButton(onPressed: onFilterPress, icon: Icon(Icons.filter_list, color: Colors.black)),
                    ),
                    controller: searchController,
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.filter_list),
                //   onPressed: () => {}
                // ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            // child: ListView(
            //   children: List.generate(20, (index) => new ProductItem())
            // ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: productsList.length,
              separatorBuilder: (BuildContext context, int index) => Container(height: 16,),
              itemBuilder: (BuildContext context, int index) {
                return ProductItem(product: productsList.elementAt(index));
              },
            )
          ),
        ],
      ),
    ),
    );
  }
}
