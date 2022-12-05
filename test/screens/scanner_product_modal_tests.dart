import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/scanner_product_modal.dart';
import 'package:inzynierka/services/auth_user_service.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';

import 'scanner_product_modal_tests.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductRepository>(),
  MockSpec<UserService>(),
  MockSpec<AuthUserService>(),
])
void main() {
  late AppUser? authUser;
  late Product? product;
  late String barcode;

  late MockProductRepository mockProductRepository;
  late MockUserService mockUserService;
  late MockAuthUserService mockAuthUserService;

  buildWidget() => wrapForTesting(
        ScannerProductModal(id: barcode),
        overrides: [
          productRepositoryProvider.overrideWith((ref) => mockProductRepository),
          userServiceProvider.overrideWith((ref) => mockUserService),
          authUserServiceProvider.overrideWith((ref) => mockAuthUserService),
          authUserProvider.overrideWith((ref) => authUser),
          productProvider.overrideWith((ref, id) => product)

        ],
      );

  setUp(() {
    authUser = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    product = Product(
      id: '111111',
      name: 'Produkt',
      user: authUser!.id,
      addedDate: FirestoreDateTime.serverTimestamp(),
    );

    barcode = product!.id;

    mockProductRepository = MockProductRepository();
    mockUserService = MockUserService();
    mockAuthUserService = MockAuthUserService();
  });

  group('unknownProduct', () {
    setUp(() {
      product = null;
    });

    testWidgets('Should show unknown product info', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Nieznany produkt'), findsOneWidget);
    });

    testWidgets('Should show barcode scan', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining(barcode), findsOneWidget);
    });

    testWidgets('Should not show add product button', (tester) async {
      authUser = null;

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Uzupełnij informacje'), findsNothing);
    });

    testWidgets('Should show add product button for user', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Uzupełnij informacje'), findsOneWidget);
    });

    testWidgets('Should show product form modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.bySemanticsLabel('Uzupełnij informacje'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nowy produkt'), findsOneWidget);
    });
  });

  group('product', () {
    testWidgets('Should show product info', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining(product!.name), findsOneWidget);
      expect(find.textContaining(product!.id), findsOneWidget);
    });

    testWidgets('Should show product modal on tap', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.bySemanticsLabel('Więcej informacji'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Oznaczenia'), findsOneWidget);
    });

    testWidgets('Should change user savedProducts on tap', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.bySemanticsLabel('Zapisz na liście'));
      await tester.pumpAndSettle();

      verify(mockAuthUserService.updateSavedProduct(barcode)).called(1);
    });
  });
}
