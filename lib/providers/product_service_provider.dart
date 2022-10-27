import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/image_upload_service_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';

final productServiceProvider = Provider(ProductService.new);

class ProductService {
  ProductService(this.ref);

  final Ref ref;

  Future<Product> createFromModel(ProductFormModel model) async {
    final productRepository = ref.read(productRepositoryProvider);
    final imageUploadService = ref.read(imageUploadServiceProvider);
    // todo: unnecessary cast to File
    final photoFile = File(model.photo!.path);
    final photosPath = 'products/${model.id}';
    final photoUrls = await Future.wait<String>(
      [
        imageUploadService.uploadWithFile(photoFile, '$photosPath/original.png', width: 500, height: 500),
        imageUploadService.uploadWithFile(photoFile, '$photosPath/small.png', width: 80, height: 80),
      ],
    );
    final user = ref.watch(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final product = Product(
      id: model.id,
      name: model.name,
      keywords: [...model.keywords],
      photo: photoUrls[0],
      photoSmall: photoUrls[1],
      symbols: [...model.symbols],
      sortProposals: {
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
      // todo
      addedDate: DateTime.now(),
    );
    return productRepository.create(product);
  }

  Future<Product?> findVariant(List<String> keywords) async {
    final productRepository = ref.read(productRepositoryProvider);
    final query = productRepository.collection.where('keywords', arrayContainsAny: keywords).limit(1);
    final snapshot = await query.get();
    return snapshot.docs.firstOrNull?.data();
  }
}
