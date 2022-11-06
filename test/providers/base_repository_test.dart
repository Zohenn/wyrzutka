import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/identifiable.dart';
import 'package:inzynierka/providers/base_repository.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

final _testCacheProvider = createCacheProvider<_Test>();

final _testRepositoryProvider = Provider(_TestRepository.new);

class _Test with Identifiable {
  _Test(this.id, this.a, this.b);

  factory _Test.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data()!;
    return _Test(snapshot.id, data['a'], data['b']);
  }

  @override
  String id;
  int a;
  String b;

  static Map<String, Object?> toFirestore(_Test item, SetOptions? options) {
    return {
      'a': item.a,
      'b': item.b,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Test && runtimeType == other.runtimeType && id == other.id && a == other.a && b == other.b;

  @override
  int get hashCode => id.hashCode ^ a.hashCode ^ b.hashCode;
}

class _TestRepository extends BaseRepository<_Test> {
  _TestRepository(this.ref);

  @override
  Ref ref;

  @override
  CacheNotifier<_Test> get cache => ref.read(_testCacheProvider.notifier);

  @override
  CollectionReference<_Test> get collection => ref.read(firebaseFirestoreProvider).collection('test').withConverter(
        fromFirestore: _Test.fromFirestore,
        toFirestore: _Test.toFirestore,
      );

  @override
  String? getId(_Test item) => item.id.isNotEmpty ? item.id : null;
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _TestRepository repository;
  late ProviderContainer container;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
      ],
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    createContainer();
    repository = container.read(_testRepositoryProvider);
  });

  group('create', () {
    test('Should create new with random id if not supplied', () async {
      final item = _Test('', 1, 'b');
      final id = await repository.create(item);
      final savedData = (await repository.collection.doc(id).get()).data()!;

      expect(id, isNotEmpty);
      expect(
        savedData,
        isA<_Test>().having((o) => o.id, 'id', id).having((o) => o.a, 'a', item.a).having((o) => o.b, 'b', item.b),
      );
    });

    test('Should create new with given id', () async {
      final item = _Test('id', 1, 'b');
      final id = await repository.create(item);
      final savedData = (await repository.collection.doc(id).get()).data()!;

      expect(id, isNotEmpty);
      expect(savedData, equals(item));
    });
  });

  group('update', () {
    late Map<String, dynamic> data;
    late _Test item;

    setUp(() async {
      data = {'a': 2, 'b': 'c'};
      item = _Test('id', 1, 'b');
      await repository.collection.doc(item.id).set(item);
      repository.addToCache(item.id, item);
    });

    test('Should update item with given id', () async {
      await repository.update(item.id, data);
      final savedData = (await repository.collection.doc(item.id).get()).data()!;

      expect(savedData, isA<_Test>().having((o) => o.a, 'a', 2).having((o) => o.b, 'b', 'c'));
    });

    test('Should add updated item to cache', () async {
      final updatedItem = _Test(item.id, data['a'], data['b']);
      await repository.update(item.id, data, updatedItem);

      expect(repository.cache[item.id], equals(updatedItem));
    });
  });

  group('fetchAll', () {
    late List<_Test> items;

    setUp(() async {
      items = [
        _Test('1', 1, 'a'),
        _Test('2', 2, 'b'),
      ];
      for (var item in items) {
        await repository.collection.doc(item.id).set(item);
      }
    });

    test('Should fetch all items', () async {
      final _items = await repository.fetchAll();
      expect(_items, hasLength(items.length));
      expect(_items, containsAll(items));
    });

    test('Should add fetched items to cache', () async {
      await repository.fetchAll();
      expect(repository.cache, hasLength(items.length));
      expect(repository.cache.values, containsAll(items));
    });
  });

  group('fetchId', () {
    late _Test item;

    setUp(() async {
      item = _Test('id', 1, 'b');
      await repository.collection.doc(item.id).set(item);
    });

    test('Should fetch item with given id', () async {
      final _item = await repository.fetchId(item.id);

      expect(identical(_item, item), isFalse);
      expect(_item, equals(item));
    });

    test('Should add fetched item to cache', () async {
      final _item = await repository.fetchId(item.id);

      expect(repository.cache, hasLength(1));
      expect(repository.cache[item.id], equals(_item));
    });

    test('Should return null if item does not exist', () async {
      final _item = await repository.fetchId('foo');

      expect(_item, isNull);
    });
  });

  group('fetchIds', () {
    late List<_Test> items;
    late List<_Test> shouldFetch;
    late List<String> toFetch;

    setUp(() async {
      items = [
        _Test('1', 1, 'a'),
        _Test('2', 2, 'b'),
        _Test('3', 3, 'c'),
      ];
      for (var item in items) {
        await repository.collection.doc(item.id).set(item);
      }
      shouldFetch = items.take(2).toList();
      toFetch = shouldFetch.map((e) => e.id).toList();
    });

    test('Should fetch items with given id', () async {
      final _items = await repository.fetchIds(toFetch);

      expect(_items, hasLength(shouldFetch.length));
      expect(_items, containsAll(shouldFetch));
    });

    test('Should add fetched items to cache', () async {
      await repository.fetchIds(toFetch);

      expect(repository.cache, hasLength(shouldFetch.length));
      expect(repository.cache.values, containsAll(shouldFetch));
    });

    test('Should not fail if some items do not exist', () async {
      final _items = await repository.fetchIds([...toFetch, 'foo']);

      expect(_items, hasLength(shouldFetch.length));
      expect(_items, containsAll(shouldFetch));
    });

    test('Should not fail with empty list', () async {
      await expectLater(repository.fetchIds([]), completes);
    });
  });

  group('delete', () {
    late _Test item;

    setUp(() {
      item = _Test('id', 1, 'b');
    });

    test('Should delete given item', () async {
      await repository.delete(item.id);
      final savedData = (await repository.collection.doc(item.id).get()).data();

      expect(savedData, isNull);
    });

    test('Should remove deleted item from cache', () async {
      repository.addToCache(item.id, item);
      await repository.delete(item.id);

      expect(repository.cache, isEmpty);
    });
  });
}
