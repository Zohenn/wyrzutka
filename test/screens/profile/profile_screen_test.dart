import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
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

import '../../utils.dart';
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
  final AppUser regularUser = AppUser(
    id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    email: 'wojciech.brandeburg@pollub.edu.pl',
    name: 'Wojciech',
    surname: 'Brandeburg',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );
  final List<Product> products = List.generate(
    15,
    (index) => Product(
      id: 'Product$index',
      name: 'ProductName$index',
      user: 'user',
      addedDate: FirestoreDateTime.serverTimestamp(),
      snapshot: MockDocumentSnapshot(),
    ),
  );

  final modUser = regularUser.copyWith(id: '2', role: Role.mod, name: 'mod', surname: 'mod');

  late MockProductRepository mockProductRepository;
  late MockProductService mockProductService;
  late MockAuthService mockAuthService;
  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockUserService mockUserService;

  late AppUser authUser;
  late AppUser user;

  buildWidget({AppUser? authUser, AppUser? user}) => wrapForTesting(
        ProfileScreen(),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          userProvider.overrideWith((ref, id) => user ?? authUser),
          productServiceProvider.overrideWithValue(mockProductService),
          productsProvider.overrideWith((ref, ids) => products.where((product) => ids.contains(product.id)).toList()),
          productProvider.overrideWith((ref, id) => products.firstWhere((p) => p.id == id)),
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
          productSymbolRepositoryProvider.overrideWith((ref) => mockProductSymbolRepository),
          userServiceProvider.overrideWith((ref) => mockUserService),
        ],
      );

  setUp(() {
    user = regularUser;
    authUser = modUser;

    mockProductRepository = MockProductRepository();
    mockProductService = MockProductService();
    mockAuthService = MockAuthService();
    mockProductSymbolRepository = MockProductSymbolRepository();
    mockUserService = MockUserService();
  });

  group('signed in', () {
    final profileActionsButtonFinder = find.byTooltip('Ustawienia użytkownika');

    group('profile', () {
      testWidgets('Should load user profile', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.text(authUser.displayName), findsOneWidget);
      });

      testWidgets('Should show profile actions button', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(profileActionsButtonFinder, findsOneWidget);
      });

      testWidgets('Should show action sheet modal on settings tap', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        await scrollToAndTap(tester, profileActionsButtonFinder);
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Akcje użytkownika'), findsOneWidget);
      });
    });

    group('user profile', () {
      testWidgets('Should show profile actions button in user profile with privileged role', (tester) async {
        authUser = modUser;
        assert([Role.mod, Role.admin].contains(authUser.role));
        await tester.pumpWidget(buildWidget(authUser: authUser, user: user));
        await tester.pumpAndSettle();

        expect(profileActionsButtonFinder, findsOneWidget);
      });

      testWidgets('Should not show profile actions button in user profile without privileged role', (tester) async {
        authUser = modUser.copyWith(role: Role.user);
        await tester.pumpWidget(buildWidget(authUser: authUser, user: user));
        await tester.pumpAndSettle();

        expect(profileActionsButtonFinder, findsNothing);
      });
    });

    group('savedProducts', () {
      final List<Product> savedProducts = products;
      final List<Product> nextProducts = savedProducts.skip(10).take(5).toList();

      setUp(() {
        authUser = authUser.copyWith(savedProducts: savedProducts.map((p) => p.id).toList());
      });

      testWidgets('Should show saved products page button', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        tester.ensureSemantics();

        expect(find.bySemanticsLabel('Pokaż wszystko Zapisane produkty'), findsOneWidget);
      });


      testWidgets('Should not show saved products page button', (tester) async {
        authUser = authUser.copyWith(savedProducts: savedProducts.take(2).map((p) => p.id).toList());

        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Pokaż wszystko Zapisane produkty'), findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        Finder finder = find.byTooltip(products[0].name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(products[0].id), findsOneWidget);
      });

      group('savedProducts page', () {
        setUp(() {
          when(mockProductRepository.fetchIds(any)).thenAnswer((realInvocation) => Future.value(nextProducts));
        });
        testWidgets('Should open saved products page on tap', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Zapisane produkty'));
          await tester.pumpAndSettle();

          expect(find.textContaining('ProductName3'), findsOneWidget);
        });

        testWidgets('Should fetch more products if scrolled to the bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Zapisane produkty'));
          await tester.pumpAndSettle();

          clearInteractions(mockProductRepository);

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();

          verify(mockProductRepository.fetchIds(any)).called(1);
        });

        testWidgets('Should show new products if scrolled to bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Zapisane produkty'));
          await tester.pumpAndSettle();

          clearInteractions(mockProductRepository);

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();
          // scroll a bit more so new products slide into view
          await tester.dragFrom(Offset(300, 500), Offset(0, -500));
          await tester.pumpAndSettle();

          for (var product in nextProducts) {
            expect(find.text(product.name), findsOneWidget);
          }
        });
      });
    });

    group('sortProposals', () {
      final List<Product> sortProposals = products.take(10).toList();
      final List<Product> nextProducts = products.skip(10).take(5).toList();

      initFetchSortProposals() =>
          mockProductService.fetchNextVerifiedSortProposalsForUser(user: anyNamed('user'), batchSize: 2);
      initPageFetchSortProposals() => mockProductService.fetchNextVerifiedSortProposalsForUser(user: anyNamed('user'));
      countSortProposals() => mockProductService.countVerifiedSortProposalsForUser(any);
      fetchSortProposals() =>
          mockProductService.fetchNextVerifiedSortProposalsForUser(
              user: anyNamed('user'), startAfterDocument: argThat(isNotNull, named: 'startAfterDocument'));

      setUp(() {
        when(initFetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals.take(2).toList()));
        when(initPageFetchSortProposals()).thenAnswer((realInvocation) => Future.value(sortProposals));
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(products.length));
        when(fetchSortProposals()).thenAnswer((realInvocation) => Future.value(nextProducts));
      });

      testWidgets('Should show sort proposals page button', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji'), findsOneWidget);
      });

      testWidgets('Should not show sort proposals page button', (tester) async {
        when(countSortProposals()).thenAnswer((realInvocation) => Future.value(2));

        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji'), findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        Finder finder = find.byTooltip(products[0].name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(products[0].id), findsOneWidget);
      });

      group('sortProposals page', () {
        testWidgets('Should open sort proposals page on tap', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji'));
          await tester.pumpAndSettle();

          verify(initPageFetchSortProposals()).called(1);
          expect(find.textContaining(sortProposals[3].name), findsOneWidget);
        });

        testWidgets('Should fetch more products if scrolled to the bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji'));
          await tester.pumpAndSettle();

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();

          verify(fetchSortProposals()).called(1);
        });

        testWidgets('Should show new products if scrolled to bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Propozycje segregacji'));
          await tester.pumpAndSettle();

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();
          // scroll a bit more so new products slide into view
          await tester.dragFrom(Offset(300, 500), Offset(0, -400));
          await tester.pumpAndSettle();

          for (var product in nextProducts) {
            expect(find.text(product.name), findsOneWidget);
          }
        });
      });
    });

    group('userProducts', () {
      final List<Product> userProducts = products.take(10).toList();
      final List<Product> nextProducts = products.skip(10).take(5).toList();

      initFetchUserProducts() =>
          mockProductService.fetchNextProductsAddedByUser(user: anyNamed('user'), batchSize: 2);
      initPageFetchUserProducts() => mockProductService.fetchNextProductsAddedByUser(user: anyNamed('user'));
      countUserProducts() => mockProductService.countProductsAddedByUser(any);
      fetchUserProducts() =>
          mockProductService.fetchNextProductsAddedByUser(
              user: anyNamed('user'), startAfterDocument: argThat(isNotNull, named: 'startAfterDocument'));

      setUp(() {
        when(initFetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts.take(2).toList()));
        when(initPageFetchUserProducts()).thenAnswer((realInvocation) => Future.value(userProducts));
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(products.length));
        when(fetchUserProducts()).thenAnswer((realInvocation) => Future.value(nextProducts));
      });

      testWidgets('Should show user products page button', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Pokaż wszystko Dodane produkty'), findsOneWidget);
      });

      testWidgets('Should not show user products page button', (tester) async {
        when(countUserProducts()).thenAnswer((realInvocation) => Future.value(2));

        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Pokaż wszystko Dodane produkty'), findsNothing);
      });

      testWidgets('Should open product modal on product tap', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: authUser));
        await tester.pumpAndSettle();

        Finder finder = find.byTooltip(products[0].name);
        expect(finder, findsOneWidget);

        await scrollToAndTap(tester, finder);
        await tester.pumpAndSettle();

        expect(find.textContaining(products[0].id), findsOneWidget);
      });

      group('userProducts page', () {
        testWidgets('Should open sort proposals page on tap', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Dodane produkty'));
          await tester.pumpAndSettle();

          verify(initPageFetchUserProducts()).called(1);
          expect(find.textContaining(userProducts[3].name), findsOneWidget);
        });

        testWidgets('Should fetch more products if scrolled to the bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Dodane produkty'));
          await tester.pumpAndSettle();

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();

          verify(fetchUserProducts()).called(1);
        });

        testWidgets('Should show new products if scrolled to bottom', (tester) async {
          await tester.pumpWidget(buildWidget(authUser: authUser));
          await tester.pumpAndSettle();

          await scrollToAndTap(tester, find.bySemanticsLabel('Pokaż wszystko Dodane produkty'));
          await tester.pumpAndSettle();

          await tester.dragFrom(Offset(300, 500), Offset(0, -600));
          await tester.pumpAndSettle();
          // scroll a bit more so new products slide into view
          await tester.dragFrom(Offset(300, 500), Offset(0, -400));
          await tester.pumpAndSettle();

          for (var product in nextProducts) {
            expect(find.text(product.name), findsOneWidget);
          }
        });
      });
    });
  });

  group('not signed in', () {
    testWidgets('Should show profile features', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: null));

      expect(find.textContaining('Zaloguj się'), findsWidgets);
      expect(find.textContaining('Zarejestruj się'), findsWidgets);
    });

    testWidgets('Should load sign up modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: null));

      Finder finder = find.textContaining('Zarejestruj się');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Rejestracja'), findsWidgets);
    });

    testWidgets('Should load sign in modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: null));

      final buttonFinder = find.textContaining('Zaloguj się');
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      textSpanOnTap(buttonFinder, 'Zaloguj się');
      await tester.pumpAndSettle();

      expect(find.textContaining('Logowanie'), findsWidgets);
    });
  });
}
