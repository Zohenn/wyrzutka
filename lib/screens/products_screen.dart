import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/widgets/custom_popup_menu_button.dart';
import 'package:inzynierka/widgets/generic_popup_menu_item.dart';
import 'package:inzynierka/widgets/radio_popup_menu_item.dart';

final _selectedFiltersProvider = StateProvider((ref) => <String, dynamic>{});
final _futureProvider = FutureProvider((ref) => ref.watch(productsFutureProvider.future));
final _innerFutureProvider = FutureProvider((ref) {
  final selectedFilters = ref.watch(_selectedFiltersProvider);
  if(selectedFilters.isEmpty){
    return ref.read(_futureProvider.future);
  }
  return ref.read(productRepositoryProvider).fetchMore(selectedFilters);
});

class ProductsScreen extends HookConsumerWidget {
  const ProductsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterGroups = [
      FilterGroup(
        ProductSortFilters.groupKey,
        ProductSortFilters.groupName,
        [
          for (var filter in ProductSortFilters.values) Filter(filter.filterName, filter),
        ],
      ),
    ];
    final selectedFilters = ref.watch(_selectedFiltersProvider);
    final _future = ref.watch(_futureProvider);
    final _innerFuture = ref.watch(_innerFutureProvider);
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
          child: _future.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(err.toString()),
            ),
            data: (products) => NestedScrollView(
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
                              hintText: 'Wyszukaj',
                              prefixIcon: Icon(Icons.search, color: Colors.black),
                              // todo: change suffix to clear button if search text is not empty
                              suffixIcon: FilterButton(
                                groups: filterGroups,
                                selectedFilters: selectedFilters,
                                onChanged: (newFilters) => ref.read(_selectedFiltersProvider.notifier).state = newFilters,
                              ),
                            ),
                            selectionControls: CustomColorSelectionHandle(Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              body: _innerFuture.when(
                loading: () => const Center(child: CircularProgressIndicator(),),
                error: (err, stack) => Center(child: Text(err.toString())),
                data: (products) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  itemCount: products.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterGroup<T> {
  const FilterGroup(this.key, this.name, this.filters);

  final String key;
  final String name;
  final List<Filter<T>> filters;
}

class Filter<T> {
  const Filter(this.name, this.value);

  final String name;
  final T value;
}

class FilterButton extends HookWidget {
  const FilterButton({
    Key? key,
    required this.groups,
    required this.selectedFilters,
    required this.onChanged,
  }) : super(key: key);

  final List<FilterGroup> groups;
  final Map<String, dynamic> selectedFilters;
  final void Function(Map<String, dynamic>) onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenuButton(
      icon: const Icon(Icons.filter_list),
      itemBuilder: (context) => [
        for (var group in groups) ...[
          GenericPopupMenuItem(
            type: PopupMenuItemType.presentation,
            child: Text(group.name),
          ),
          for (var filter in group.filters)
            RadioPopupMenuItem<dynamic>(
              radioValue: filter.value,
              groupValue: selectedFilters[group.key],
              onChanged: (val) {
                final newFilters = {
                  ...selectedFilters,
                  group.key: filter.value,
                };
                onChanged(newFilters);
              },
              child: Text(filter.name),
            ),
          GenericPopupMenuItem(
            type: PopupMenuItemType.action,
            backgroundColor: Theme.of(context).primaryColorLight,
            onTap: () => onChanged({}),
            child: Center(
              child: Text('Wyczyść'),
            ),
          ),
        ],
      ],
    );
  }
}
