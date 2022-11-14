import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/debounce.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/product_filters.dart';
import 'package:inzynierka/repositories/base_repository.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/search_input.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/screens/widgets/product_item.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/custom_color_selection_handle.dart';
import 'package:inzynierka/widgets/filter_bottom_sheet.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/load_more_list_view.dart';

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
    final productService = ref.watch(productServiceProvider);
    final isMounted = useIsMounted();
    final productIds = useState<List<String>>([]);
    final initialProductIds = useRef<List<String>>([]);
    final products = ref.watch(productsProvider(productIds.value));
    final future = useInitFuture<List<Product>>(
      () => ref.read(productsFutureProvider).then((value) {
        productIds.value = value.map((product) => product.id).toList();
        initialProductIds.value = productIds.value;
        return value;
      }),
    );
    final searchText = useState('');
    final selectedFilters = useState<Filters>({});
    final innerFuture = useState<Future?>(null);
    final fetchedAll = useState(false);

    useEffect(() {
      if (searchText.value.isNotEmpty) {
        innerFuture.value = productService.search(searchText.value).then((value) async {
          productIds.value = value.map((product) => product.id).toList();
        });
      } else {
        innerFuture.value = ref.read(productsFutureProvider).then((value) async {
          if (isMounted()) {
            productIds.value = value.map((product) => product.id).toList();
            fetchedAll.value = false;
          }
        });
      }

      return null;
    }, [searchText.value]);

    useEffect(() {
      innerFuture.value = productService.fetchNext(filters: selectedFilters.value.values.toList()).then((value) {
        productIds.value = value.map((product) => product.id).toList();
        fetchedAll.value = false;
      });
      return null;
    }, [selectedFilters.value]);

    useEffect(() {
      return () {
        // todo:
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //   productRepository.invalidateCache(productIds.value.toSet().difference(initialProductIds.value.toSet()).toList());
        // });
      };
    }, []);

    return SafeArea(
      child: FutureHandler(
        future: future,
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
            data: () => ConditionalBuilder(
              condition: products.isNotEmpty,
              ifTrue: () => LoadMoreListView(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                itemCount: products.length,
                showLoading: searchText.value.isNotEmpty,
                canLoad: productIds.value.length >= BaseRepository.batchSize && !fetchedAll.value,
                onLoad: () => asyncCall(
                  context,
                  () => productService
                      .fetchNext(
                          filters: selectedFilters.value.values.toList(), startAfterDocument: products.last.snapshot!)
                      .then((value) {
                    if (isMounted()) {
                      productIds.value = [...productIds.value, ...value.map((product) => product.id)];
                      fetchedAll.value = value.length < BaseRepository.batchSize;
                    }
                  }),
                ),
                itemBuilder: (BuildContext context, int index) => ProductItem(product: products[index]),
                loadingBuilder: (context) => ConditionalBuilder(
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
    );
  }
}

class _FilterSection extends StatelessWidget {
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
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
              selectionColor: Colors.black26,
            ),
      ),
      child: SearchInput(
        readOnly: selectedFilters.isNotEmpty,
        onSearch: onSearch,
        hintText: 'Wyszukaj produkty',
        trailingBuilder: (context) => IconButton(
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
      ),
    );
  }
}
