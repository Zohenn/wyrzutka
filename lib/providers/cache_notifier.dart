import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef CacheProvider<V> = StateNotifierProvider<CacheNotifier<V>, Map<String, V>>;

CacheProvider<V> createCacheProvider<V>() {
  return StateNotifierProvider<CacheNotifier<V>, Map<String, V>>((ref) => CacheNotifier<V>());
}

ProviderFamily<V?, String> createCacheItemProvider<V>(CacheProvider<V> cacheProvider) {
  return Provider.family<V?, String>((ref, id) {
    final cache = ref.watch(cacheProvider);
    return cache[id];
  });
}

class CacheNotifier<V> extends StateNotifier<Map<String, V>> {
  CacheNotifier() : super({});

  void add(String key, V value) {
    state = {
      ...state,
      key: value,
    };
  }

  void clear() {
    state = {};
  }

  V? operator [](String key) {
    return state[key];
  }

  void operator []=(String key, V value) {
    add(key, value);
  }
}

mixin CacheNotifierMixin<V> {
  Ref get ref;

  @protected
  CacheNotifier<V> get cache;

  @protected
  CollectionReference<V> get collection;

  Future<V?> fetchId(String id, [bool skipCache = false]) async {
    if (!skipCache && cache[id] != null) {
      return cache[id];
    }
    final snapshot = await collection.doc(id.toString()).get();
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

  @protected
  List<V> mapDocs(QuerySnapshot<V> querySnapshot, [bool clearCache = false]) {
    if (clearCache) {
      cache.clear();
    }

    return querySnapshot.docs.map((snapshot) {
      final data = snapshot.data();
      addToCache(snapshot.id, data);
      return data;
    }).toList();
  }

  @protected
  void addToCache(String key, V? value) {
    if (value != null) {
      cache[key] = value;
    }
  }
}