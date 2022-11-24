import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/product_filters.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/products_screen.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'products_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductRepository>(),
  MockSpec<ProductService>(),
  MockSpec<UserRepository>(),
  MockSpec<ProductSymbolRepository>(),
  MockSpec<DocumentSnapshot>(),
])
void main() {
  final products = List.generate(
    12,
    (index) => Product(
      id: '$index',
      name: 'Product$index',
      user: 'user',
      addedDate: FirestoreDateTime.serverTimestamp(),
      snapshot: MockDocumentSnapshot(),
    ),
  );
  final initialProducts = products.take(10).toList();
  final searchProducts = products.skip(2).take(5).toList();
  final filters = {
    ProductSortFilters.groupKey: [ProductSortFilters.verified],
    ProductContainerFilters.groupKey: [ProductContainerFilters.plastic],
  };
  final filterProducts = products.skip(5).take(3).toList();
  late MockProductRepository mockProductRepository;
  late MockProductService mockProductService;
  late MockUserRepository mockUserRepository;
  late MockProductSymbolRepository mockProductSymbolRepository;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        ProductsScreen(),
        overrides: [
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          productServiceProvider.overrideWithValue(mockProductService),
          productProvider.overrideWith((ref, id) => products.firstWhere((element) => element.id == id)),
          productsProvider.overrideWith((ref, ids) => products.where((element) => ids.contains(element.id)).toList()),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
        ],
      ),
    );

    await tester.pumpAndSettle();
  }

  selectFilters(WidgetTester tester) async {
    await scrollToAndTap(tester, find.byTooltip('Filtry'));
    await tester.pumpAndSettle();
    final context = getContext(tester);
    Navigator.of(context).pop(filters);
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockProductRepository = MockProductRepository();
    when(mockProductRepository.fetchNext()).thenAnswer((realInvocation) => Future.value(initialProducts));
    mockProductService = MockProductService();
    when(mockProductService.search(any)).thenAnswer((realInvocation) => Future.value(searchProducts));
    when(mockProductService.fetchNextForCustomFilters(
            filters: anyNamed('filters'), startAfterDocument: anyNamed('startAfterDocument')))
        .thenAnswer((realInvocation) => Future.value(filterProducts));
    mockUserRepository = MockUserRepository();
    mockProductSymbolRepository = MockProductSymbolRepository();
  });

  testWidgets('Should fetch products on init', (tester) async {
    await buildWidget(tester);

    verify(mockProductRepository.fetchNext()).called(1);
  });

  testWidgets('Should show fetched products', (tester) async {
    await buildWidget(tester);

    for (var product in initialProducts) {
      expect(find.text(product.name, skipOffstage: false), findsOneWidget);
    }
  });

  testWidgets('Should open product on tap', (tester) async {
    await buildWidget(tester);

    final product = initialProducts.first;
    await scrollToAndTap(tester, find.text(product.name));
    await tester.pumpAndSettle();

    expect(find.text(product.name), findsNWidgets(2));
  });

  group('searching', () {
    testWidgets('Should call ProductService.search on search', (tester) async {
      await buildWidget(tester);

      const searchText = 'searchText';
      await tester.enterText(find.bySemanticsLabel('Wyszukaj produkty'), searchText);
      // wait for debounce to kick in
      await tester.pumpAndSettle(Duration(seconds: 1));

      verify(mockProductService.search(searchText)).called(1);
    });

    testWidgets('Should show found products after search', (tester) async {
      await buildWidget(tester);

      await tester.enterText(find.bySemanticsLabel('Wyszukaj produkty'), 'Search text');
      // wait for debounce to kick in
      await tester.pumpAndSettle(Duration(seconds: 1));

      for (var product in searchProducts) {
        expect(find.text(product.name), findsOneWidget);
      }
    });

    testWidgets('Should show message if found no products', (tester) async {
      when(mockProductService.search(any)).thenAnswer((realInvocation) => Future.value([]));
      await buildWidget(tester);

      await tester.enterText(find.bySemanticsLabel('Wyszukaj produkty'), 'Search text');
      // wait for debounce to kick in
      await tester.pumpAndSettle(Duration(seconds: 1));

      expect(find.textContaining('Nie znaleziono'), findsOneWidget);
    });

    testWidgets('Should show default list of products if search text is cleared', (tester) async {
      await buildWidget(tester);

      await tester.enterText(find.bySemanticsLabel('Wyszukaj produkty'), 'Search text');
      // wait for debounce to kick in
      await tester.enterText(find.bySemanticsLabel('Wyszukaj produkty'), '');
      // wait for debounce to kick in again
      await tester.pumpAndSettle(Duration(seconds: 1));

      for (var product in initialProducts) {
        expect(find.text(product.name, skipOffstage: false), findsOneWidget);
      }
    });
  });

  group('filtering', () {
    testWidgets('Should open filters sheet on tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, find.byTooltip('Filtry'));
      await tester.pumpAndSettle();

      expect(find.text('Wybierz filtry'), findsOneWidget);
    });

    testWidgets('Should fetch products for selected filters', (tester) async {
      await buildWidget(tester);

      await selectFilters(tester);

      verify(mockProductService.fetchNextForCustomFilters(filters: filters.values.toList(), startAfterDocument: null))
          .called(1);
    });

    testWidgets('Should show found products after filtering', (tester) async {
      await buildWidget(tester);

      await selectFilters(tester);

      for (var product in filterProducts) {
        expect(find.text(product.name), findsOneWidget);
      }
    });

    testWidgets('Should show message if found no products', (tester) async {
      when(mockProductService.fetchNextForCustomFilters(
              filters: anyNamed('filters'), startAfterDocument: anyNamed('startAfterDocument')))
          .thenAnswer((realInvocation) => Future.value([]));
      await buildWidget(tester);

      await selectFilters(tester);

      expect(find.textContaining('Nie znaleziono'), findsOneWidget);
    });
  });

  group('fetching more products', () {
    late List<Product> nextProducts;

    setUp(() {
      nextProducts = products.skip(10).toList();

      when(
        mockProductService.fetchNextForCustomFilters(
          filters: anyNamed('filters'),
          startAfterDocument: null,
        ),
      ).thenAnswer((realInvocation) => Future.value(initialProducts));
      when(
        mockProductService.fetchNextForCustomFilters(
          filters: anyNamed('filters'),
          startAfterDocument: argThat(isNotNull, named: 'startAfterDocument'),
        ),
      ).thenAnswer((realInvocation) => Future.value(nextProducts));
    });

    testWidgets('Should fetch more products if scrolled to the bottom', (tester) async {
      await buildWidget(tester);
      await selectFilters(tester);

      await tester.dragFrom(Offset(300, 500), Offset(0, -600));
      await tester.pumpAndSettle();

      verify(
        mockProductService.fetchNextForCustomFilters(
          filters: filters.values.toList(),
          startAfterDocument: products[9].snapshot,
        ),
      ).called(1);
    });

    testWidgets('Should show new products if scrolled to bottom', (tester) async {
      await buildWidget(tester);
      await selectFilters(tester);

      await tester.dragFrom(Offset(300, 500), Offset(0, -600));
      await tester.pumpAndSettle();
      // scroll a bit more so new products slide into view
      await tester.dragFrom(Offset(300, 500), Offset(0, -300));
      await tester.pumpAndSettle();

      for (var product in nextProducts) {
        expect(find.text(product.name), findsOneWidget);
      }
    });
  });
}
