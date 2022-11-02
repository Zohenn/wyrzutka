import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inzynierka/providers/cache_notifier.dart';

abstract class BaseRepository<V> with CacheNotifierMixin<V> {
  bool _fetchedAll = false;

  String? getId(V item);

  Future<String> create(V item) async {
    final doc = collection.doc(getId(item));
    await doc.set(item);
    return doc.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    final doc = collection.doc(id);
    await doc.update(data);
  }

  Future<List<V>> fetchAll() async {
    if(_fetchedAll){
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
    final snapshot = await collection.doc(id).get();
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

  Future<void> delete(String id) async {
    await collection.doc(id).delete();
    removeFromCache(id);
  }
}