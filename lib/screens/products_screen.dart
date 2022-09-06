import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:inzynierka/widgets/filter_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
                                  final result = await showDefaultBottomSheet<Filters>(
                                    context: context,
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