import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/elements/product_item.dart';
import 'package:inzynierka/models/sort.dart';
import 'package:inzynierka/models/sortElement.dart';

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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductsScreen> {
  final searchController = TextEditingController();

  final productsList = [
    const Product(
      id: 354789,
      name: "Woda niegazowana",
      photo: "woda",
      symbols: [],
      sort: Sort(elements: [
        SortElement(container: ElementContainer.plastic, name: 'Nakrętka', description: 'Odkręć i wyrzuć oddzielnie'),
        SortElement(container: ElementContainer.plastic, name: 'Butelka', description: 'Zgnieć przed wyrzuceniem')
      ]),
      verifiedBy: 'xxx',
      containers: ['plastic'],
      user: "1",
      sortProposals: [],
    ),
    const Product(
      id: 145697,
      name: "Napój energetyczny",
      photo: "",
      symbols: [],
      sort: Sort(
        elements: [
          SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
        ],
      ),
      verifiedBy: '2',
      containers: ['plastic'],
      sortProposals: [],
      user: "1",
    ),
    const Product(
      id: 547145,
      name: "Chusteczki",
      photo: "",
      symbols: ["1", "2"],
      sort: Sort(
        elements: [
          SortElement(name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
          SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
        ],
      ),
      verifiedBy: '2',
      containers: ['paper', 'mixed'],
      user: "1",
      sortProposals: [],
    ),
    const Product(
      id: 025896,
      name: "Papier toaletowy",
      photo: "",
      symbols: [],
      sortProposals: [],
      user: "1",
    ),
    const Product(
      id: 254896,
      name: "Frugo",
      photo: "",
      symbols: [],
      sort: Sort(
        elements: [
          SortElement(name: 'Puszka', container: ElementContainer.plastic, description: 'Zgnieć przed wyrzuceniem')
        ],
      ),
      user: "2",
      sortProposals: [],
    ),
    const Product(
        id: 485769,
        name: "Ręcznik papierowy",
        photo: "",
        symbols: ["1", "2"],
        sortProposals: [
          Sort(
            elements: [
              SortElement(
                  name: 'Opakowanie', container: ElementContainer.paper, description: 'Zgnieć przed wyrzuceniem'),
              SortElement(name: 'Zużyte chusteczki', container: ElementContainer.mixed)
            ],
          )
        ],
        user: "1"),
    const Product(id: 485769, name: "Ręcznik papierowy", photo: "", symbols: ["1", "2"], sortProposals: [], user: "1"),
  ];

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
                  color: Theme.of(context).primaryColorLight,
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
                          suffixIcon: IconButton(
                              onPressed: onFilterPress, icon: const Icon(Icons.filter_list, color: Colors.black)),
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
