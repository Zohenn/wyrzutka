import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/profile/dialog/profile_role_dialog.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'profile_role_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserService>()])
void main() {
  final AppUser regularUser = AppUser(
    id: '1',
    email: 'email',
    name: 'Wojciech',
    surname: 'Brandeburg',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );

  final modUser = regularUser.copyWith(id: '2', role: Role.mod, name: 'mod', surname: 'mod');
  final adminUser = regularUser.copyWith(id: '3', role: Role.admin, name: 'admin', surname: 'admin');
  final privilegedUsers = [modUser, adminUser];

  late MockUserService mockUserService;

  buildWidget(AppUser authUser) => wrapForTesting(
        ProfileRoleDialog(user: regularUser),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          userServiceProvider.overrideWith((ref) => mockUserService)
        ],
      );

  setUp(() {
    mockUserService = MockUserService();
  });

  testWidgets('Should close dialog on tap', (tester) async {
    await tester.pumpWidget(buildWidget(modUser));

    await scrollToAndTap(tester, find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Nowa rola'), findsNothing);
  });

  testWidgets('Should close modal on success', (tester) async {
    when(mockUserService.changeRole(any , any)).thenAnswer((realInvocation) => Future.value());
    await tester.pumpWidget(buildWidget(modUser));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Nowa rola'), findsNothing);
  });

  testWidgets('Should change role on tap', (tester) async {
    await tester.pumpWidget(buildWidget(modUser));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    verify(mockUserService.changeRole(any, any)).called(1);
  });

  for (var privilegedUser in privilegedUsers) {
    testWidgets('Should show roles for ${privilegedUser.role.name} user', (tester) async {
      await tester.pumpWidget(buildWidget(privilegedUser));
      await tester.pumpAndSettle();

      final dropdown = find.byKey(ValueKey('Dropdown'));

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final availableRoles = Role.values.where((element) => element.index <= privilegedUser.role.index);
      for (var role in availableRoles) {
        expect(find.byKey(ValueKey(role.desc)), findsWidgets);
      }
    });
  }
}
