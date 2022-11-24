import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/product_modal/product_actions_sheet.dart';
import 'package:inzynierka/services/auth_user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'product_actions_sheet_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthUserService>()])
void main() {
  final product = Product(id: '1', name: 'Product name', user: 'user', addedDate: FirestoreDateTime.serverTimestamp());
  final regularUser = AppUser(
    id: '1',
    email: 'email',
    name: 'name',
    surname: 'surname',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );
  final regularUserWithSavedProduct = regularUser.copyWith(savedProducts: [product.id]);
  final modUser = regularUser.copyWith(id: '2', role: Role.mod);
  final adminUser = regularUser.copyWith(id: '3', role: Role.admin);
  final privilegedUsers = [modUser, adminUser];
  late MockAuthUserService mockAuthUserService;
  late AppUser authUser;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        ProductActionsSheet(product: product),
        overrides: [
          authUserServiceProvider.overrideWithValue(mockAuthUserService),
          authUserProvider.overrideWith((ref) => authUser),
        ],
      ),
    );
  }

  setUp(() {
    mockAuthUserService = MockAuthUserService();
    authUser = regularUser;
  });

  testWidgets('Should call AuthUserService.updateSavedProduct on save', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.textContaining('Zapisz'));
    await tester.pumpAndSettle();

    verify(mockAuthUserService.updateSavedProduct(product.id)).called(1);
  });

  testWidgets('Should call AuthUserService.updateSavedProduct on remove from saved', (tester) async {
    authUser = regularUserWithSavedProduct;
    await buildWidget(tester);

    await scrollToAndTap(tester, find.textContaining('Usuń'));
    await tester.pumpAndSettle();

    verify(mockAuthUserService.updateSavedProduct(product.id)).called(1);
  });

  testWidgets('Should not call AuthUserService.updateSavedProduct when save is in progress', (tester) async {
    final completer = Completer();
    when(mockAuthUserService.updateSavedProduct(any)).thenAnswer((realInvocation) => completer.future);
    await buildWidget(tester);

    await scrollToAndTap(tester, find.textContaining('Zapisz'));
    await tester.pump();
    clearInteractions(mockAuthUserService);
    await tester.tap(find.textContaining('Zapisz'));
    await tester.pump();

    verifyNoMoreInteractions(mockAuthUserService);
  });

  group('button visibility', () {
    testWidgets('Should not show edit button for regular user', (tester) async {
      await buildWidget(tester);

      expect(find.text('Edytuj informacje'), findsNothing);
    });

    testWidgets('Should not show delete button for regular user', (tester) async {
      await buildWidget(tester);

      expect(find.text('Usuń produkt'), findsNothing);
    });

    for(var user in privilegedUsers){
      testWidgets('Should show edit button for ${user.role.name} user', (tester) async {
        authUser = user;
        await buildWidget(tester);

        expect(find.text('Edytuj informacje'), findsOneWidget);
      });

      testWidgets('Should show delete button for ${user.role.name} user', (tester) async {
        authUser = user;
        await buildWidget(tester);

        expect(find.text('Usuń produkt'), findsOneWidget);
      });
    }
  });

  group('privileged user buttons', () {
    setUp(() {
      authUser = modUser;
    });

    testWidgets('Should open product edit form on edit tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, find.text('Edytuj informacje'));
      await tester.pumpAndSettle();

      expect(find.text('Edycja produktu'), findsOneWidget);
    });

    testWidgets('Should open product delete dialog on tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, find.text('Usuń produkt'));
      await tester.pumpAndSettle();

      expect(find.text('Anuluj'), findsOneWidget);
    });
  });
}
