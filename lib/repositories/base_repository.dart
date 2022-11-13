import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/identifiable.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/repositories/query_filter.dart';

abstract class BaseRepository<V extends Identifiable> with CacheNotifierMixin<V> {
  Ref get ref;

  @protected
  CollectionReference<V> get collection;

  static const int batchSize = 10;

  bool _fetchedAll = false;

  DocumentReference<V> getDoc(String? id) => collection.doc(id);

  Future<String> create(V item) async {
    final doc = getDoc(item.id.isNotEmpty ? item.id : null);
    await doc.set(item);
    return doc.id;
  }

  Future<void> update(String id, Map<String, dynamic> data, [V? item]) async {
    final doc = getDoc(id);
    await doc.update(data);
    if (item != null) {
      addToCache(id, item);
    }
  }

  Future<List<V>> fetchAll() async {
    if (_fetchedAll) {
      return cache.values.toList();
    }

    final snapshot = await collection.get();
    mapDocs(snapshot);
    _fetchedAll = true;
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<V?> fetchId(String id, [bool skipCache = false]) async {
    if (!skipCache && cache[id] != null) {
      return cache[id];
    }
    final snapshot = await getDoc(id).get();
    final data = snapshot.data();
    addToCache(snapshot.id, data);
    return data;
  }

  /// Will return only those ids that were fetched successfully or present in cache,
  /// meaning the output list might be shorter than the input one.
  Future<List<V>> fetchIds(List<String> ids) async {
    final idsToFetch = ids.where((element) => cache[element] == null).toList();
    if (idsToFetch.isNotEmpty) {
      final snapshot = await collection.where(FieldPath.documentId, whereIn: idsToFetch).get();
      mapDocs(snapshot);
    }
    return ids
        .map((e) {
          return cache[e];
        })
        .where((element) => element != null)
        .cast<V>()
        .toList();
  }

  Query<V> _applyFilters(Query<V> query, List<QueryFilter> filters) {
    for (var filter in filters) {
      query = filter.apply(query);
    }
    return query;
  }

  Future<List<V>> fetchNext({
    List<QueryFilter> filters = const [],
    DocumentSnapshot? startAfterDocument,
    int batchSize = BaseRepository.batchSize,
  }) async {
    Query<V> query = _applyFilters(collection.limit(batchSize), filters);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    final querySnapshot = await query.get();
    return mapDocs(querySnapshot);
  }

  Future<List<V>> search(String searchKey, String value) async {
    value = value.toLowerCase();
    final querySnapshot = await collection.orderBy(searchKey).startAt([value]).endAt(['$value\uf8ff']).limit(5).get();
    return mapDocs(querySnapshot);
  }

  Future<int> count({List<QueryFilter> filters = const []}) async {
    Query<V> query = _applyFilters(collection, filters);
    final querySnapshot = await query.count().get();
    return querySnapshot.count;
  }

  Future<void> delete(String id) async {
    await getDoc(id).delete();
    removeFromCache(id);
  }
}
