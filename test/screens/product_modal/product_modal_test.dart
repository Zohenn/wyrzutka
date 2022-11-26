import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/product_modal/product_modal.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../utils.dart';
import 'product_modal_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductRepository>(), MockSpec<ProductSymbolRepository>(), MockSpec<UserRepository>()])
void main() {
  final user = AppUser(
    id: '1',
    email: 'email',
    name: 'name',
    surname: 'surname',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );
  final symbols = List.generate(
      2, (index) => ProductSymbol(id: '${index + 1}', name: 'Symbol${index + 1}', photo: 'photo$index.jpg'));
  late List<Product> products;
  late List<Product> variants;
  late Product product;
  late MockProductRepository mockProductRepository;
  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockUserRepository mockUserRepository;
  late AppUser? authUser;

  buildWidget(WidgetTester tester, [String? productId]) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        wrapForTesting(Container(), overrides: [
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          productProvider.overrideWith((ref, id) => products.firstWhereOrNull((element) => element.id == id)),
          productsProvider.overrideWith((ref, ids) => products.where((element) => ids.contains(element.id)).toList()),
          productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
          productSymbolsProvider
              .overrideWith((ref, ids) => symbols.where((element) => ids.contains(element.id)).toList()),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          userProvider.overrideWith((ref, id) => id == user.id ? user : null),
          authUserProvider.overrideWith((ref) => authUser),
        ]),
      );

      final context = getContext(tester);
      showDefaultBottomSheet(context: context, builder: (context) => ProductModal(id: productId ?? product.id));

      await tester.pumpAndSettle();
    });
  }

  buildWidgetAndOpenVariants(WidgetTester tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Warianty'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    products = List.generate(
      4,
      (index) => Product(
        id: '${index + 1}',
        name: 'Product$index',
        user: '${index + 1}',
        symbols: ['1', '2'],
        addedDate: FirestoreDateTime.serverTimestamp(),
      ),
    );
    variants = products.skip(2).toList();
    products[0] = products[0].copyWith(variants: variants.map((e) => e.id).toList());
    mockProductRepository = MockProductRepository();
    mockProductSymbolRepository = MockProductSymbolRepository();
    mockUserRepository = MockUserRepository();
    product = products.first;
    authUser = user;
  });

  testWidgets('Should fetch product by id', (tester) async {
    await buildWidget(tester);

    verify(mockProductRepository.fetchId(product.id)).called(1);
  });

  testWidgets('Should not fail when product cannot be found', (tester) async {
    await buildWidget(tester, 'foobar');

    expect(tester.takeException(), isNull);
  });

  testWidgets('Should open variants page on tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Warianty'));
    await tester.pumpAndSettle();

    expect(find.text(variants.first.name), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Warianty')).getSemanticsData(),
      isA<SemanticsData>().having((o) => o.hasFlag(SemanticsFlag.isSelected), 'isSelected', isTrue),
    );
  });

  testWidgets('Should open product page on tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Warianty'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Segregacja'));
    await tester.pumpAndSettle();

    expect(find.text('Oznaczenia'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Segregacja')).getSemanticsData(),
      isA<SemanticsData>().having((o) => o.hasFlag(SemanticsFlag.isSelected), 'isSelected', isTrue),
    );
  });

  group('product page', () {
    testWidgets('Should fetch product symbols', (tester) async {
      await buildWidget(tester);

      verify(mockProductSymbolRepository.fetchIds(product.symbols)).called(1);
    });

    testWidgets('Should fetch user for product', (tester) async {
      await buildWidget(tester);

      verify(mockUserRepository.fetchIds([product.user])).called(1);
    });

    testWidgets('Should fetch user for verified sort', (tester) async {
      product = product.copyWith(sort: Sort.verified(user: '2', elements: []));
      products[0] = product;
      await buildWidget(tester);

      verify(mockUserRepository.fetchIds([product.user, product.sort!.user]));
    });

    testWidgets('Should fetch user for each sort proposal', (tester) async {
      product = product.copyWith(
        sortProposals: {
          '1': Sort(id: '1', user: '2', elements: [], voteBalance: 0, votes: {}),
          '2': Sort(id: '2', user: '3', elements: [], voteBalance: 0, votes: {}),
        },
      );
      products[0] = product;

      await buildWidget(tester);

      verify(mockUserRepository.fetchIds([product.user, ...product.sortProposals.values.map((e) => e.user)]));
    });

    testWidgets('Should show user', (tester) async {
      await buildWidget(tester);

      expect(find.text(user.displayName), findsOneWidget);
    });

    testWidgets('Should not fail when user cannot be found', (tester) async {
      product = product.copyWith(user: 'foo');
      await buildWidget(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Should show symbols', (tester) async {
      await buildWidget(tester);

      for (var symbol in symbols) {
        expect(find.text(symbol.name), findsOneWidget);
      }
    });

    testWidgets('Should not fail when symbols cannot be found', (tester) async {
      product = product.copyWith(symbols: ['foo', 'bar']);
      await buildWidget(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Should not fail when product has no symbols', (tester) async {
      product = product.copyWith(symbols: []);
      await buildWidget(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('variant page', () {
    testWidgets('Should show variants', (tester) async {
      await buildWidgetAndOpenVariants(tester);

      for (var variant in variants) {
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('Should open variant and close current product on tap', (tester) async {
      await buildWidgetAndOpenVariants(tester);

      final variant = variants.first;
      await scrollToAndTap(tester, find.text(variant.name));
      await tester.pumpAndSettle();

      expect(find.text(product.name), findsNothing);
      expect(find.text(variant.name), findsOneWidget);
    });

    testWidgets('Should not fail when variants cannot be found', (tester) async {
      product = product.copyWith(variants: ['foo', 'bar']);
      await buildWidgetAndOpenVariants(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Should not fail when product has no variants', (tester) async {
      product = product.copyWith(variants: []);
      await buildWidgetAndOpenVariants(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('sheet button', () {
    testWidgets('Should open product actions sheet on tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, find.byTooltip('Więcej akcji'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Zapisz'), findsOneWidget);
    });

    testWidgets('Should not close product modal when product actions sheet is opened', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, find.byTooltip('Więcej akcji'));
      await tester.pumpAndSettle();

      expect(find.text(product.name), findsOneWidget);
    });

    testWidgets('Should not open product actions sheet on tap when user is not logged in', (tester) async {
      authUser = null;
      await buildWidget(tester);

      await scrollToAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget widget) => widget is Tooltip && (widget.message?.contains('Więcej akcji') ?? false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Zapisz'), findsNothing);
    });
  });
}
