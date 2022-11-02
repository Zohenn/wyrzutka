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

ProviderFamily<List<V>, List<String>> createCacheItemsProvider<V>(CacheProvider<V> cacheProvider) {
  return Provider.family<List<V>, List<String>>((ref, ids) {
    final cache = ref.watch(cacheProvider);
    return ids.map((id) => cache[id]).where((element) => element != null).cast<V>().toList();
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

  void remove(String key) {
    final stateCopy = {...state}..remove(key);
    state = stateCopy;
  }

  void removeAll(List<String> keys) {
    final stateCopy = {...state}..removeWhere((key, value) => keys.contains(key));
    state = stateCopy;
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

  int get length => state.length;

  Iterable<V> get values => state.values;
}

mixin CacheNotifierMixin<V> {
  Ref get ref;

  @protected
  CacheNotifier<V> get cache;

  @protected
  CollectionReference<V> get collection;

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

  @protected
  void removeFromCache(String key) {
    cache.remove(key);
  }

  void invalidateCache(List<String> ids){
    cache.removeAll(ids);
  }
}
