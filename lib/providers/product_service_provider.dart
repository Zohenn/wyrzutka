import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/providers/image_upload_service_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';

final productServiceProvider = Provider(ProductService.new);

class ProductService {
  ProductService(this.ref);

  final Ref ref;

  Future<Product> createFromModel(ProductFormModel model, [Product? variant]) async {
    final productRepository = ref.read(productRepositoryProvider);
    final photoUrls = await _uploadPhotos(model);
    final user = ref.watch(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final product = Product(
      id: model.id,
      name: model.name,
      keywords: [...model.keywords],
      photo: photoUrls[0],
      photoSmall: photoUrls[1],
      symbols: [...(variant != null ? variant.symbols : model.symbols)],
      sortProposals: variant != null
          ? {...variant.sortProposals}
          : {
              if (model.elements.isNotEmpty)
                sortProposalId: Sort(
                  id: sortProposalId,
                  user: user,
                  elements: model.elements.values.flattened.toList(),
                  voteBalance: 0,
                  votes: [],
                ),
            },
      user: user,
      addedDate: FirestoreDateTime.serverTimestamp(),
      verifiedBy: variant?.verifiedBy,
      sort: variant?.sort,
      variants: variant != null ? [...(variant.variants), variant.id] : [],
    );
    final batch = ref.read(firebaseFirestoreProvider).batch();
    batch.set(productRepository.collection.doc(product.id), product);
    if (variant != null) {
      for (var id in product.variants) {
        batch.update(
          productRepository.collection.doc(id),
          {
            'variants': FieldValue.arrayUnion([product.id])
          },
        );
      }
    }
    await batch.commit();
    return product;
  }

  Future<List<String>> _uploadPhotos(ProductFormModel model) async {
    final imageUploadService = ref.read(imageUploadServiceProvider);
    final photosPath = 'products/${model.id}';
    final photoUrls = await Future.wait<String>(
      [
        imageUploadService.uploadWithFile(model.photo!, '$photosPath/original.png', width: 500, height: 500),
        imageUploadService.uploadWithFile(model.photo!, '$photosPath/small.png', width: 80, height: 80),
      ],
    );
    return photoUrls;
  }

  Future<Product> updateFromModel(ProductFormModel model) async {
    final productRepository = ref.read(productRepositoryProvider);
    final photoUrls = model.photo != null ? await _uploadPhotos(model) : null;
    final updateData = {
      'name': model.name,
      'keywords': [...model.keywords],
      if (photoUrls != null) ...{
        'photo': photoUrls[0],
        'photoSmall': photoUrls[1],
      },
      'symbols': [...model.symbols],
    };
    // todo: pass this down to repository
    await productRepository.collection.doc(model.id).update(updateData);
    return model.product!.copyWith(
      name: model.name,
      keywords: [...model.keywords],
      photo: photoUrls?[0] ?? model.product!.photo,
      photoSmall: photoUrls?[1] ?? model.product!.photoSmall,
      symbols: [...model.symbols],
    );
  }

  Future<Product?> findVariant(List<String> keywords) async {
    final productRepository = ref.read(productRepositoryProvider);
    final query = productRepository.collection.where('keywords', arrayContainsAny: keywords).limit(1);
    final snapshot = await query.get();
    return snapshot.docs.firstOrNull?.data();
  }
}
