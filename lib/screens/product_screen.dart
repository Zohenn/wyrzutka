import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/elements/product_item.dart';

class CustomColorSelectionHandle extends TextSelectionControls {
  CustomColorSelectionHandle(this.handleColor) : _controls = materialTextSelectionControls;

  final Color handleColor;
  final TextSelectionControls _controls;

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) => TextSelectionTheme(
      data: TextSelectionThemeData(selectionHandleColor: handleColor), child: Builder(builder: builder));

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    return _wrapWithThemeData((BuildContext context) => _controls.buildHandle(context, type, textLineHeight));
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset position,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _controls.buildToolbar(
      context,
      globalEditableRegion,
      textLineHeight,
      position,
      endpoints,
      delegate,
      clipboardStatus,
      lastSecondaryTapDownPosition,
    );
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final searchController = TextEditingController();
  final productsList = [
    Product(name: "Woda niegazowana", photo: "woda", symbols: [], containers: ["plastic"]),
    Product(name: "Napój energetyczny", photo: "", symbols: [], containers: []),
    Product(name: "Chusteczki", photo: "", symbols: [], containers: ["paper", "mixed"]),
    Product(name: "Papier toaletowy", photo: "", symbols: [], containers: []),
    Product(name: "Frugo", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
    Product(name: "Ręcznik papierowy", photo: "", symbols: [], containers: []),
  ];

  void onSearchPress() {
    print("Search pressed");
  }

  void onFilterPress() {
    print("Filter pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
              selectionHandleColor: Colors.black,
              selectionColor: Colors.black26,
              cursorColor: Colors.black,
            ),
      ),
      child: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Container(
                height: 48,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          // border: InputBorder.none,
                          hintText: "Wyszukaj",
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          suffixIcon:
                          IconButton(onPressed: onFilterPress, icon: const Icon(Icons.filter_list, color: Colors.black)),
                        ),
                        controller: searchController,
                        selectionControls: CustomColorSelectionHandle(Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            itemCount: productsList.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
            itemBuilder: (BuildContext context, int index) => ProductItem(product: productsList[index]),
          ),
        ),
      ),
    );
  }
}
