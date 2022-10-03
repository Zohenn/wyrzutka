import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';

final _productSymbolCollection = FirebaseFirestore.instance.collection('symbols').withConverter(
      fromFirestore: ProductSymbol.fromFirestore,
      toFirestore: ProductSymbol.toFirestore,
    );

final productSymbolRepositoryProvider = Provider((ref) => ProductSymbolRepository());

Future saveExampleSymbolData() async {
  return Future.wait(symbols.map((e) {
    final doc = _productSymbolCollection.doc(e.id);
    return doc.set(e);
  }));
}

class ProductSymbolRepository {
  final Map<String, ProductSymbol> cache = {};

  Future<ProductSymbol?> fetchId(String id) async {
    if (cache[id] != null) {
      return cache[id];
    }
    final snapshot = await _productSymbolCollection.doc(id).get();
    final symbol = snapshot.data();
    _addToCache(symbol);
    return symbol;
  }

  /// Will return only those ids that were fetched successfully or present in cache,
  /// meaning the output list might be shorter than the input one.
  Future<List<ProductSymbol>> fetchIds(List<String> ids) async {
    final idsToFetch = ids.where((element) => cache[element] == null).toList();
    if (idsToFetch.isNotEmpty) {
      final snapshot = await _productSymbolCollection.where(FieldPath.documentId, whereIn: idsToFetch).get();
      for (var element in snapshot.docs) {
        _addToCache(element.data());
      }
    }
    return ids
        .map((e) {
          return cache[e];
        })
        .where((element) => element != null)
        .cast<ProductSymbol>()
        .toList();
  }

  void _addToCache(ProductSymbol? symbol) {
    if (symbol != null) {
      cache[symbol.id] = symbol;
    }
  }
}
