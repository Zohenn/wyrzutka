import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'profile_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductRepository>(),
  MockSpec<ProductService>(),
  MockSpec<AuthService>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<ProductSymbolRepository>(),
  MockSpec<UserService>(),
])
void main() {
  late MockProductRepository mockProductRepository;
  late MockProductService mockProductService;
  late MockAuthService mockAuthService;
  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockUserService mockUserService;
  late AppUser authUser;
  late AppUser user;
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
          productProvider.overrideWith((ref, id) => products.firstWhere((p) => p.id == id)),
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
          productSymbolRepositoryProvider.overrideWith((ref) => mockProductSymbolRepository),
          userServiceProvider.overrideWith((ref) => mockUserService),
        ],
      );

  buildUserWidget() => wrapForTesting(
        ProfileScreenContent(userId: user.id),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          userProvider.overrideWith((ref, id) => user),
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

    user = AppUser(
      id: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      name: 'Michał',
      surname: 'Marciniak',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    products = List.generate(
      15,
      (index) => Product(
        id: 'Product$index',
        name: 'ProductName$index',
        user: 'user',
        addedDate: FirestoreDateTime.serverTimestamp(),
        snapshot: MockDocumentSnapshot(),
      ),
    );

    mockProductRepository = MockProductRepository();
    mockProductService = MockProductService();
    mockAuthService = MockAuthService();
    mockProductSymbolRepository = MockProductSymbolRepository();
    mockUserService = MockUserService();
  });

  group('signed in', () {
    group('user', () {
      testWidgets('Should load authUser', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        expect(find.text(authUser.displayName), findsOneWidget);
      });

      testWidgets('Should load profile actions button', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        expect(find.text(authUser.displayName), findsOneWidget);

        Finder finder = find.byTooltip('Ustawienia użytkownika');
        expect(finder, findsOneWidget);
      });

      testWidgets('Should load profile actions button in user profile with role', (tester) async {
        await tester.pumpWidget(buildUserWidget());
        await tester.pumpAndSettle();

        expect(authUser.role, anyOf([Role.mod, Role.admin]));

        Finder finder = find.byTooltip('Ustawienia użytkownika');
        expect(finder, findsOneWidget);
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
        authUser = authUser.copyWith(savedProducts: List.generate(11, (index) => 'Product$index'));
      });

      testWidgets('Should open saved products page on tap', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Zapisane produkty');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('ProductName3'), findsOneWidget);
      });

      testWidgets('Should not show saved products page button', (tester) async {
        authUser = authUser.copyWith(savedProducts: ['Product1', 'Product2']);

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Zapisane produkty');
        expect(finder, findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Product product = products.firstWhere((p) => p.id == 'Product1');
        Finder finder = find.byTooltip(product.name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(product.id), findsOneWidget);
      });
    });

    group('sortProposals', () {
      late List<Product> sortProposals;

      fetchSortProposals() => mockProductService.fetchNextVerifiedSortProposalsForUser(
          user: anyNamed('user'), batchSize: anyNamed('batchSize'));
      countSortProposals() => mockProductService.countVerifiedSortProposalsForUser(any);

      setUp(() {
        sortProposals = products.where((p) => ['Product1', 'Product2', 'Product3'].contains(p.id)).toList();
      });


      testWidgets('Should open sort proposals page on tap', (tester) async {
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(products.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('ProductName3'), findsOneWidget);
      });

      testWidgets('Should not show sort proposals page button', (tester) async {
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals.take(2).toList()));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(2));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji');
        expect(finder, findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(products.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Product product = products.firstWhere((p) => p.id == 'Product1');
        Finder finder = find.byTooltip(product.name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(product.id), findsOneWidget);
      });
    });

    group('userProducts', () {
      late List<Product> userProducts;

      fetchUserProducts() =>
          mockProductService.fetchNextProductsAddedByUser(user: anyNamed('user'), batchSize: anyNamed('batchSize'));
      countUserProducts() => mockProductService.countProductsAddedByUser(any);

      setUp(() {
        userProducts = products.where((p) => ['Product2', 'Product3','Product4'].contains(p.id)).toList();
      });

      testWidgets('Should open user products page on tap', (tester) async {
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(products.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Dodane produkty');
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining('ProductName3'), findsOneWidget);
      });

      testWidgets('Should not show user products page button', (tester) async {
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts.take(2).toList()));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(2));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Finder finder = find.bySemanticsLabel('Pokaż wszystko Dodane produkty');
        expect(finder, findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(products.length));

        await tester.pumpWidget(buildAuthUserWidget());
        await tester.pumpAndSettle();

        Product product = products.firstWhere((p) => p.id == 'Product2');
        Finder finder = find.byTooltip(product.name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(product.id), findsOneWidget);
      });
    });
  });

  group('not signed in', () {
    testWidgets('Should show profile features', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.textContaining('Zaloguj się'), findsWidgets);
      expect(find.textContaining('Zarejestruj się'), findsWidgets);
    });

    testWidgets('Should load sign up modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      Finder finder = find.textContaining('Zarejestruj się');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Rejestracja'), findsWidgets);
    });

    testWidgets('Should load sign in modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      final buttonFinder = find.textContaining('Zaloguj się');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      textSpanOnTap(buttonFinder, 'Zaloguj się');
      await tester.pumpAndSettle();

      expect(find.textContaining('Logowanie'), findsWidgets);
    });
  });
}
