import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/widgets/filter_bottom_sheet.dart';
import 'package:inzynierka/widgets/future_builder.dart';

final _filterGroups = [
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

class ProductsScreen extends HookConsumerWidget {
  const ProductsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = useState<Future?>(null);
    final selectedFilters = useState<Filters>({});
    final innerFuture = useState<Future?>(null);
    final products = useState<List<Product>>([]);
    final isFetchingMore = useState(false);
    final fetchedAll = useState(false);
    useEffect(() {
      future.value = ref.read(productsFutureProvider.future).then((value) {
        products.value.addAll(value);
      });
      return null;
    }, []);
    useEffect(() {
      innerFuture.value = ref.read(productRepositoryProvider).fetchMore(filters: selectedFilters.value).then((value) {
        products.value..clear()..addAll(value);
        fetchedAll.value = false;
      });
      return null;
    }, [selectedFilters.value]);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
                selectionColor: Colors.black26,
              ),
        ),
        child: SafeArea(
          child: FutureHandler(
            future: future.value,
            data: () => NestedScrollView(
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
                                      groups: _filterGroups,
                                      selectedFilters: selectedFilters.value,
                                    ),
                                  );

                                  if (result != null) {
                                    selectedFilters.value = result;
                                    // ref.read(_selectedFiltersProvider.notifier).state = result;
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
              body: FutureHandler(
                future: innerFuture.value,
                data: () => NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 50.0 &&
                        products.value.length >= 10 &&
                        !fetchedAll.value &&
                        !isFetchingMore.value) {
                      isFetchingMore.value = true;
                      final repository = ref.read(productRepositoryProvider);
                      repository
                          .fetchMore(filters: selectedFilters.value, startAfterDocument: products.value.last.snapshot!)
                          .then((value) {
                            products.value = [...products.value, ...value];
                        // ref.read(_productsProvider.notifier).addProducts(value);
                        fetchedAll.value = value.length < ProductRepository.batchSize;
                      }).catchError((err, stack) {
                        // todo
                      }).whenComplete(() => isFetchingMore.value = false);
                    }

                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    itemCount: isFetchingMore.value ? products.value.length + 1 : products.value.length,
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                    itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
                      condition: index < products.value.length,
                      ifTrue: () => ProductItem(product: products.value[index]),
                      ifFalse: () => Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
