import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/debounce.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/providers/product_symbol_provider.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/widgets/filter_bottom_sheet.dart';
import 'package:inzynierka/widgets/future_handler.dart';

final _filterGroups = [
  FilterGroup(
    ProductSortFilters.groupKey,
    ProductSortFilters.groupName,
    [
      for (var filter in ProductSortFilters.values) Filter(filter.filterName, filter),
    ],
  ),
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
    final searchText = useState('');
    final selectedFilters = useState<Filters>({});
    final innerFuture = useState<Future?>(null);
    final products = useState<List<Product>>([]);
    final isFetchingMore = useState(false);
    final fetchedAll = useState(false);
    useEffect(() {
      future.value = ref.read(productsFutureProvider).then((value) {
        products.value.addAll(value);
      });
      return null;
    }, []);

    useEffect(() {
      if (searchText.value.isNotEmpty) {
        innerFuture.value = ref.read(productRepositoryProvider).search(searchText.value).then((value) {
          products.value
            ..clear()
            ..addAll(value);
        });
      } else {
        innerFuture.value = ref.read(productsFutureProvider).then((value) {
          products.value
            ..clear()
            ..addAll(value);
          fetchedAll.value = false;
        });
      }

      return null;
    }, [searchText.value]);

    useEffect(() {
      innerFuture.value = ref.read(productRepositoryProvider).fetchMore(filters: selectedFilters.value).then((value) {
        products.value
          ..clear()
          ..addAll(value);
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _FilterSection(
                      selectedFilters: selectedFilters.value,
                      onFiltersChanged: (filters) => selectedFilters.value = filters,
                      onSearch: (String value) => searchText.value = value,
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
                        debugPrint(err.toString());
                        debugPrintStack(stackTrace: stack);
                        // todo
                      }).whenComplete(() => isFetchingMore.value = false);
                    }

                    return false;
                  },
                  child: ConditionalBuilder(
                    condition: products.value.isNotEmpty,
                    ifTrue: () => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      itemCount: isFetchingMore.value || searchText.value.isNotEmpty
                          ? products.value.length + 1
                          : products.value.length,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
                        condition: index < products.value.length,
                        ifTrue: () => ProductItem(product: products.value[index]),
                        ifFalse: () => ConditionalBuilder(
                          condition: searchText.value.isEmpty,
                          ifTrue: () => const Center(child: CircularProgressIndicator()),
                          ifFalse: () => Center(
                            child: Text(
                              'W przypadku wyszukiwania po nazwie wyświetlanych jest 5 najbardziej trafnych wyników.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ifFalse: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/empty_cart.svg',
                            width: MediaQuery.of(context).size.width * 0.5,
                          ),
                          const SizedBox(height: 24.0),
                          Text('Nie znaleziono produktów', style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
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

class _FilterSection extends HookWidget {
  const _FilterSection({
    Key? key,
    required this.selectedFilters,
    required this.onSearch,
    required this.onFiltersChanged,
  }) : super(key: key);

  final Filters selectedFilters;
  final void Function(String) onSearch;
  final void Function(Filters) onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchText = useState('');
    final debounce = useDebounceHook(onEmit: (value) => onSearch(value));

    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: selectedFilters.isNotEmpty,
            controller: searchController,
            cursorColor: Colors.black,
            onChanged: (value) {
              debounce.onChanged(value);
              searchText.value = value;
            },
            decoration: InputDecoration(
              hintText: 'Wyszukaj',
              hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).hintColor),
              // fillColor: Theme.of(context).primaryColorLight,
              fillColor: selectedFilters.isEmpty ? Theme.of(context).primaryColorLight : Theme.of(context).dividerColor,
              enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder!.copyWith(
                    borderSide: BorderSide.none,
                  ),
              focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder!.copyWith(
                    borderSide: BorderSide.none,
                  ),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: ConditionalBuilder(
                condition: searchText.value.isEmpty,
                ifTrue: () => IconButton(
                  style: selectedFilters.isEmpty
                      ? null
                      : ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(Colors.white),
                          side: MaterialStatePropertyAll(
                            BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                          ),
                        ),
                  onPressed: () async {
                    final result = await showDefaultBottomSheet<Filters>(
                      context: context,
                      builder: (context) => FilterBottomSheet(
                        groups: _filterGroups,
                        selectedFilters: selectedFilters,
                        single: true,
                      ),
                    );

                    if (result != null) {
                      onFiltersChanged(result);
                    }
                  },
                  icon: const Icon(Icons.filter_list),
                ),
                ifFalse: () => IconButton(
                  onPressed: () {
                    debounce.cancel();
                    searchText.value = '';
                    searchController.text = '';
                    onSearch('');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
            selectionControls: CustomColorSelectionHandle(Colors.black),
          ),
        ),
      ],
    );
  }
}
