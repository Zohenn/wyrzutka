import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../utils.dart';
import 'profile_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductRepository>(),
  MockSpec<ProductService>(),
  MockSpec<AuthService>(),
])
void main() {
  late MockProductRepository mockProductRepository;
  late MockProductService mockProductService;
  late MockAuthService mockAuthService;
  late AppUser authUser;
  late List<Product> products;

  buildWidget() => wrapForTesting(
        ProfileScreen(),
        overrides: [
          authUserProvider.overrideWith((ref) => null),
        ],
      );

  buildAuthUserWidget() => wrapForTesting(
        ProfileScreen(),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          userProvider.overrideWith((ref, id) => authUser),
          productServiceProvider.overrideWithValue(mockProductService),
          productsProvider.overrideWith((ref, ids) => products.where((product) => ids.contains(product.id)).toList()),
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          authServiceProvider.overrideWithValue(mockAuthService)
        ],
      );

  setUp(() {
    authUser = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
      savedProducts: [],
    );

    products = [
      Product(id: 'foo', name: 'foo product', user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1', addedDate: FirestoreDateTime.serverTimestamp()),
      Product(id: 'bar', name: 'bar product', user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1', addedDate: FirestoreDateTime.serverTimestamp()),
      Product(id: 'baz', name: 'baz product', user: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1', addedDate: FirestoreDateTime.serverTimestamp()),
    ];

    mockProductRepository = MockProductRepository();
    mockProductService = MockProductService();
    mockAuthService = MockAuthService();
  });

  group('signed in', () {
    group('user', () {
      testWidgets('Should load authUser', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        expect(find.text(authUser.displayName), findsOneWidget);
      });

      testWidgets('Should load action sheet modal on settings tap', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.byTooltip('Ustawienia użytkownika');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Akcje użytkownika'), findsOneWidget);
      });
    });

    group('savedProducts', () {
      setUp(() {
        authUser = authUser.copyWith(savedProducts: ['foo', 'bar', 'baz']);
      });

      testWidgets('Should open saved products page on tap', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Zapisane produkty');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('Zapisane produkty'), findsOneWidget);
      });

      testWidgets('Should not show saved products page button', (tester) async {
        authUser = authUser.copyWith(savedProducts: ['foo', 'bar']);

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Zapisane produkty');
        expect(finder, findsNothing);

      });

      testWidgets('Should open product modal on product tap', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.byTooltip('foo product');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('foo'), findsOneWidget);
      });
    });

    group('sortProposals', () {
      late List<Product> sortProposals;
      late int count;

      fetchSortProposals() => mockProductService.fetchNextVerifiedSortProposalsForUser(user: anyNamed('user'), batchSize: anyNamed('batchSize'));
      countSortProposals() => mockProductService.countVerifiedSortProposalsForUser(any);

      setUp(() {
        sortProposals = products.where((p) => ['foo', 'bar'].contains(p.id)).toList();
        count = products.length;
      });

      testWidgets('Should open sort proposals page on tap', (tester) async {
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(count));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('Propozycje segregacji'), findsOneWidget);
      });

      testWidgets('Should not show sort proposals page button', (tester) async {
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji');
        expect(finder, findsNothing);
      });
    });

    group('userProducts', () {
      late List<Product> userProducts;
      late int count;

      fetchUserProducts() => mockProductService.fetchNextProductsAddedByUser(user: anyNamed('user'), batchSize: anyNamed('batchSize'));
      countUserProducts() => mockProductService.countProductsAddedByUser(any);

      setUp(() {
        userProducts = products.where((p) => ['bar', 'baz'].contains(p.id)).toList();
        count = products.length;
      });

      testWidgets('Should open user products page on tap', (tester) async {
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(count));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Dodane produkty');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('Dodane produkty'), findsOneWidget);
      });

      testWidgets('Should not show user products page button', (tester) async {
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Dodane produkty');
        expect(finder, findsNothing);
      });
    });
  });

  group('not signed in', () {
    testWidgets('Should show profile features', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.textContaining('Zaloguj się'), findsWidgets);
      expect(find.textContaining('Zarejestruj się'), findsWidgets);
    });
  });
}
