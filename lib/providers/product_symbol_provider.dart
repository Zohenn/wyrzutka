import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/providers/cache_notifier.dart';

final _productSymbolCollection = FirebaseFirestore.instance.collection('symbols').withConverter(
      fromFirestore: ProductSymbol.fromFirestore,
      toFirestore: ProductSymbol.toFirestore,
    );

final _productSymbolCacheProvider = createCacheProvider<ProductSymbol>();

final productProvider = createCacheItemProvider(_productSymbolCacheProvider);

final productSymbolRepositoryProvider = Provider((ref) => ProductSymbolRepository(ref));

Future saveExampleSymbolData() async {
  return Future.wait(symbols.map((e) {
    final doc = _productSymbolCollection.doc(e.id);
    return doc.set(e);
  }));
}

class ProductSymbolRepository with CacheNotifierMixin<ProductSymbol> {
  ProductSymbolRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<ProductSymbol> get cache => ref.read(_productSymbolCacheProvider.notifier);

  @override
  CollectionReference<ProductSymbol> get collection => _productSymbolCollection;
}
