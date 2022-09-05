import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/widgets/custom_popup_menu_button.dart';
import 'package:inzynierka/widgets/generic_popup_menu_item.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductsScreen> {
  final searchController = TextEditingController();

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
                          decoration: const InputDecoration(
                            hintText: "Wyszukaj",
                            prefixIcon: Icon(Icons.search, color: Colors.black),
                            // todo: change suffix to clear button if search text is not empty
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
      icon: const Icon(Icons.filter_list),
      itemBuilder: (context) => [
        const GenericPopupMenuItem(
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
                const SizedBox(width: 8.0),
                Text(filter.name),
              ],
            ),
          ),
      ],
    );
  }
}