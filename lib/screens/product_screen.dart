import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/elements/product_item.dart';
import 'package:inzynierka/widgets/custom_popup_menu_button.dart';

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
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Theme(
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
                            suffixIcon: FilterButton(),
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
      ),
    );
  }
}

class Filter {
  const Filter(this.name, this.value);

  final String name;
  final String value;
}

const _filters = [
  Filter('Zweryfikowano', 'verified'),
  Filter('Niezweryfikowano', 'unverified'),
  Filter('Brak propozycji', ''),
];

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenuButton(
      icon: Icon(Icons.filter_list),
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: Theme.of(context).cardTheme.shape,
      itemBuilder: (context) => [
        GenericPopupMenuItem(
          type: PopupMenuItemType.presentation,
          child: Text('Segregacja'),
        ),
        for (var filter in _filters)
          GenericPopupMenuItem(
            child: Row(
              children: [
                Radio(
                  value: filter,
                  groupValue: _filters.first,
                  onChanged: (val) {},
                  activeColor: AppColors.positive,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                SizedBox(width: 8.0),
                Text(filter.name),
              ],
            ),
          ),
      ],
    );
  }
}

enum PopupMenuItemType {
  presentation,
  action,
}

class GenericPopupMenuItem<T> extends PopupMenuItem<T> {
  const GenericPopupMenuItem({
    super.key,
    super.value,
    super.enabled,
    super.padding,
    super.height,
    super.mouseCursor,
    super.child,
    this.type = PopupMenuItemType.action,
  });

  final PopupMenuItemType type;

  @override
  PopupMenuItemState<T, GenericPopupMenuItem<T>> createState() => _GenericPopupMenuItemState<T>();
}

class _GenericPopupMenuItemState<T> extends PopupMenuItemState<T, GenericPopupMenuItem<T>> {
  @override
  void handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final bool isClickable = widget.type == PopupMenuItemType.action;
    TextStyle style = widget.textStyle ?? popupMenuTheme.textStyle ?? theme.textTheme.subtitle1!;

    if (!widget.enabled) {
      style = style.copyWith(color: theme.disabledColor);
    }

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: isClickable ? 8.0 : 16.0),
        child: buildChild(),
      ),
    );

    if (!widget.enabled) {
      final bool isDark = theme.brightness == Brightness.dark;
      item = IconTheme.merge(
        data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
        child: item,
      );
    }

    return MergeSemantics(
      child: Semantics(
        enabled: widget.enabled,
        button: true,
        child: InkWell(
          onTap: (widget.enabled && isClickable) ? handleTap : null,
          canRequestFocus: widget.enabled,
          child: item,
        ),
      ),
    );
  }
}
