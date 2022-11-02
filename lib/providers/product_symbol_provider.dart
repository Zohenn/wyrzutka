import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/providers/base_repository.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

final _productSymbolCacheProvider = createCacheProvider<ProductSymbol>();

final productSymbolProvider = createCacheItemProvider(_productSymbolCacheProvider);
final productSymbolsProvider = createCacheItemsProvider(_productSymbolCacheProvider);
final allProductSymbolsProvider = Provider((ref) => ref.watch(_productSymbolCacheProvider).values);

final productSymbolRepositoryProvider = Provider((ref) => ProductSymbolRepository(ref));

Future saveExampleSymbolData(WidgetRef ref) async {
  return Future.wait(symbols.map((e) {
    final doc = ref.read(productSymbolRepositoryProvider).collection.doc(e.id);
    return doc.set(e);
  }));
}

class ProductSymbolRepository extends BaseRepository<ProductSymbol> {
  ProductSymbolRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<ProductSymbol> get cache => ref.read(_productSymbolCacheProvider.notifier);

  @override
  late final CollectionReference<ProductSymbol> collection =
      ref.read(firebaseFirestoreProvider).collection('symbols').withConverter(
            fromFirestore: ProductSymbol.fromFirestore,
            toFirestore: ProductSymbol.toFirestore,
          );

  @override
  String? getId(ProductSymbol item) => item.id;
}
