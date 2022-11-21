import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/repositories/query_filter.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<DocumentSnapshot>(),
])
void main() {
  late AppUser user;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  }

  setUp(() {
    user = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    mockUserRepository = MockUserRepository();
    createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('updateRole', () {
    late Role role;

    setUp(() {
      role = Role.user;
    });

    test('Should call update for correct user id', () async {
      await container.read(userServiceProvider).changeRole(user, role);
      verify(mockUserRepository.update(user.id, any, any)).called(1);
    });

    test('Should update role', () async {
      await container.read(userServiceProvider).changeRole(user, role);

      final updateData = verify(mockUserRepository.update(any, captureAny, any)).captured.first;
      expect(
        updateData,
        isA<Map<String, dynamic>>().having((o) => o['role'], 'role', role.name),
      );
    });

    test('Should update user', () async {
      await container.read(userServiceProvider).changeRole(user, role);

      final updateUser = verify(mockUserRepository.update(any, any, captureAny)).captured.first;
      expect(
        updateUser,
        isA<AppUser>().having((u) => u.role, 'role', role),
      );
    });
  });

  group('searchUser', () {
    late String searchValue;

    setUp(() {
      searchValue = 'Brandeburg Wojciech';
    });

    test('Should call search from repository', () async {
      await container.read(userServiceProvider).search(searchValue);

      verify(mockUserRepository.search('searchNS', searchValue)).called(1);
      verify(mockUserRepository.search('searchSN', searchValue)).called(1);
    });

    test('Should return user', () async {
      when(mockUserRepository.search(any, searchValue)).thenAnswer((realInvocation) => Future.value([user]));

      final searchUsers = await container.read(userServiceProvider).search(searchValue);
      expect(
        searchUsers.first,
        isA<AppUser>().having((o) => o.name, 'name', user.name).having((o) => o.surname, 'surname', user.surname),
      );
    });
  });

  group('fetchNextModeration', () {
    late DocumentSnapshot snapshot;

    setUp(() async {
      snapshot = MockDocumentSnapshot();
    });

    test('Should call fetchNext from repository', () async {
      await container.read(userServiceProvider).fetchNextModeration(snapshot);

      verify(
        mockUserRepository.fetchNext(
          filters: anyNamed('filters'),
          startAfterDocument: snapshot,
        ),
      ).called(1);
    });

    test('Should check for right roles', () async {
      await container.read(userServiceProvider).fetchNextModeration(snapshot);

      final filters = verify(mockUserRepository.fetchNext(filters: captureAnyNamed('filters'), startAfterDocument: anyNamed('startAfterDocument')))
          .captured
          .first as List<QueryFilter>;
      final filter = filters.first;
      expect(filters, hasLength(1));
      expect(
        filter,
        isA<QueryFilter>()
            .having((o) => o.field, 'field', 'role')
            .having((o) => o.operator, 'operator', FilterOperator.whereIn)
            .having((o) => o.value, 'value', [Role.mod, Role.admin].map((e) => e.name).toList()),
      );
    });
  });
}
