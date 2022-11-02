import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product/sort_element_template.dart';
import 'package:inzynierka/providers/base_repository.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

final _sortElementTemplateCacheProvider = createCacheProvider<SortElementTemplate>();

final allSortElementTemplatesProvider = Provider((ref) => ref.watch(_sortElementTemplateCacheProvider).values);

final sortElementTemplateRepositoryProvider = Provider((ref) => SortElementTemplateRepository(ref));

Future saveExampleSortElementTemplateData(WidgetRef ref) async {
  return Future.wait(sortElementTemplates.map((e) {
    final doc = ref.read(sortElementTemplateRepositoryProvider).collection.doc(e.id);
    return doc.set(e);
  }));
}

class SortElementTemplateRepository extends BaseRepository<SortElementTemplate> {
  SortElementTemplateRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<SortElementTemplate> get cache => ref.read(_sortElementTemplateCacheProvider.notifier);

  @override
  late final CollectionReference<SortElementTemplate> collection =
      ref.read(firebaseFirestoreProvider).collection('sortElementTemplates').withConverter(
            fromFirestore: SortElementTemplate.fromFirestore,
            toFirestore: SortElementTemplate.toFirestore,
          );

  @override
  String? getId(SortElementTemplate item) => item.id;
}
