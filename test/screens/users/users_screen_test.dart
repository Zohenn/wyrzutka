import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:wyrzutka/screens/users/users_screen.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:wyrzutka/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'users_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserService>(),
  MockSpec<ProductRepository>(),
  MockSpec<ProductService>(),
  MockSpec<DocumentSnapshot>(),
])
void main() {
  final users = [
    AppUser(
      id: '1',
      email: 'email1@gmail.com',
      name: 'Jan',
      surname: 'Kowalski',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    ),
    AppUser(
      id: '2',
      email: 'email2@gmail.com',
      name: 'Andrzej',
      surname: 'Nowak',
      role: Role.admin,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    ),
    AppUser(
      id: '3',
      email: 'email3@gmail.com',
      name: 'Tomasz',
      surname: 'Wójcik',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    ),
    AppUser(
      id: '4',
      email: 'email4@gmail.com',
      name: 'Karol',
      surname: 'Wójcicki',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    ),
    AppUser(
      id: '5',
      email: 'email5@gmail.com',
      name: 'Janusz',
      surname: 'Filipiak',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    ),
  ];
  final moderationTeam = users.where((element) => element.role == Role.mod || element.role == Role.admin).toList();
  final searchUsers = users.skip(3).toList();
  final generatedUsers = List.generate(
    12,
    (index) => AppUser(
      id: '$index',
      email: 'email$index@gmail.com',
      name: 'Name$index',
      surname: 'Surname$index',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
      snapshot: MockDocumentSnapshot(),
    ),
  );
  late MockUserService mockUserService;
  late MockProductRepository mockProductRepository;
  late MockProductService mockProductService;

  buildWidget(WidgetTester tester, [List<AppUser>? userSource]) async {
    final _users = userSource ?? users;
    await tester.pumpWidget(
      wrapForTesting(
        UsersScreen(),
        overrides: [
          userServiceProvider.overrideWithValue(mockUserService),
          userProvider.overrideWith((ref, id) => _users.firstWhereOrNull((element) => element.id == id)),
          usersProvider.overrideWith((ref, ids) => _users.where((element) => ids.contains(element.id)).toList()),
          productRepositoryProvider.overrideWithValue(mockProductRepository),
          productServiceProvider.overrideWithValue(mockProductService),
        ],
      ),
    );

    await tester.pumpAndSettle();
  }

  setUp(() {
    mockUserService = MockUserService();
    when(mockUserService.fetchNextModeration()).thenAnswer((realInvocation) => Future.value([...moderationTeam]));
    when(mockUserService.search(any)).thenAnswer((realInvocation) => Future.value([...searchUsers]));
    mockProductRepository = MockProductRepository();
    mockProductService = MockProductService();
  });

  testWidgets('Should fetched users from moderation team on init', (tester) async {
    await buildWidget(tester);

    verify(mockUserService.fetchNextModeration()).called(1);
  });

  testWidgets('Should show fetched users from moderation team', (tester) async {
    await buildWidget(tester);

    for (var user in moderationTeam) {
      expect(find.text(user.displayName), findsOneWidget);
    }
  });

  testWidgets('Should open profile for fetched user on tap', (tester) async {
    await buildWidget(tester);

    final user = moderationTeam.first;
    await scrollToAndTap(tester, find.text(user.displayName));
    await tester.pumpAndSettle();

    expect(find.text(user.displayName), findsNWidgets(2));
  });

  testWidgets('Should call UserService.search on search', (tester) async {
    await buildWidget(tester);

    const searchText = 'Search text';
    await tester.enterText(find.bySemanticsLabel('Wyszukaj użytkowników'), searchText);
    // wait for debounce to kick in
    await tester.pumpAndSettle(Duration(seconds: 1));

    verify(mockUserService.search(searchText)).called(1);
  });

  testWidgets('Should show found users after search', (tester) async {
    await buildWidget(tester);

    await tester.enterText(find.bySemanticsLabel('Wyszukaj użytkowników'), 'Search text');
    // wait for debounce to kick in
    await tester.pumpAndSettle(Duration(seconds: 1));

    for (var user in searchUsers) {
      expect(find.text(user.displayName), findsOneWidget);
    }
  });

  group('fetching more users', () {
    late List<AppUser> initialUsers;
    late List<AppUser> nextUsers;

    setUp(() {
      initialUsers = generatedUsers.take(10).toList();
      nextUsers = generatedUsers.skip(10).toList();
      when(mockUserService.fetchNextModeration(null)).thenAnswer((realInvocation) => Future.value(initialUsers));
      when(mockUserService.fetchNextModeration(argThat(isNotNull)))
          .thenAnswer((realInvocation) => Future.value(nextUsers));
    });

    testWidgets('Should fetch more users if scrolled to the bottom', (tester) async {
      await buildWidget(tester, generatedUsers);

      clearInteractions(mockUserService);

      await tester.dragFrom(Offset(300, 500), Offset(0, -600));
      await tester.pumpAndSettle();

      verify(mockUserService.fetchNextModeration(generatedUsers[9].snapshot)).called(1);
    });

    testWidgets('Should show new users if scrolled to the bottom', (tester) async {
      await buildWidget(tester, generatedUsers);

      clearInteractions(mockUserService);

      await tester.dragFrom(Offset(300, 500), Offset(0, -600));
      await tester.pumpAndSettle();
      // scroll a bit more so new users slide into view
      await tester.dragFrom(Offset(300, 500), Offset(0, -300));
      await tester.pumpAndSettle();

      for (var user in nextUsers) {
        expect(find.text(user.displayName), findsOneWidget);
      }
    });
  });
}
