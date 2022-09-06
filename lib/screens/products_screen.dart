import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef Filters = Map<String, dynamic>;

final _selectedFiltersProvider = StateProvider((ref) => <String, dynamic>{});
final _futureProvider = FutureProvider((ref) => ref.watch(productsFutureProvider.future));
final _innerFutureProvider = FutureProvider((ref) {
  final selectedFilters = ref.watch(_selectedFiltersProvider);
  if (selectedFilters.isEmpty) {
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
      // todo: handle these filters
      FilterGroup(
        ProductContainerFilters.groupKey,
        ProductContainerFilters.groupName,
        [
          for (var filter in ProductContainerFilters.values) Filter(filter.filterName, filter),
        ],
      ),
    ];
    final selectedFilters = ref.watch(_selectedFiltersProvider);
    final future = ref.watch(_futureProvider);
    final innerFuture = ref.watch(_innerFutureProvider);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
                selectionColor: Colors.black26,
              ),
        ),
        child: SafeArea(
          child: future.when(
            loading: () => const Center(child: CircularProgressIndicator()),
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
                              prefixIcon: const Icon(Icons.search, color: Colors.black),
                              // todo: change suffix to clear button if search text is not empty
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  final result = await showMaterialModalBottomSheet<Filters>(
                                    context: context,
                                    useRootNavigator: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    builder: (context) => FilterBottomSheet(
                                      groups: filterGroups,
                                      selectedFilters: selectedFilters,
                                    ),
                                  );

                                  if (result != null) {
                                    ref.read(_selectedFiltersProvider.notifier).state = result;
                                  }
                                },
                                icon: const Icon(Icons.filter_list),
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
              body: innerFuture.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
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

class FilterBottomSheet extends HookWidget {
  const FilterBottomSheet({
    Key? key,
    required this.groups,
    required this.selectedFilters,
  }) : super(key: key);

  final List<FilterGroup> groups;
  final Filters selectedFilters;

  @override
  Widget build(BuildContext context) {
    final localFilters = useState(selectedFilters);
    return DefaultBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColorLight,
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 16.0),
                Text(
                  'Wybierz filtry',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GutterColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var group in groups)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Wrap(
                        runSpacing: 8.0,
                        spacing: 8.0,
                        children: [
                          for (var filter in group.filters)
                            CustomFilterChip(
                              filter: filter,
                              selected: localFilters.value[group.key] == filter.value,
                              onSelected: () {
                                localFilters.value = {
                                  ...localFilters.value,
                                  group.key: filter.value,
                                };
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).primaryColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop({}),
                  style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
                        backgroundColor: const MaterialStatePropertyAll(Colors.white),
                        side: MaterialStatePropertyAll(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                  child: const Text('Wyczyść'),
                ),
                const SizedBox(width: 8.0),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(localFilters.value),
                  child: const Text('Zastosuj'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    Key? key,
    required this.filter,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  final Filter filter;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(filter.name),
          ),
        ),
      ),
    );
  }
}