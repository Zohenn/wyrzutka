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

  Future<Product> create(ProductFormModel model) async {
    final imageUploadService = ref.read(imageUploadServiceProvider);
    final photoFile = File(model.photo!.path);
    final photosPath = 'products/${model.id}';
    final photoUrls = await Future.wait<String>(
      [
        imageUploadService.uploadWithFile(photoFile, '$photosPath/original.png', width: 500, height: 500),
        imageUploadService.uploadWithFile(photoFile, '$photosPath/small.png', width: 80, height: 80),
      ],
    );
    final user = ref.watch(authUserProvider)!.id;
    final product = Product(
      id: model.id,
      name: model.name,
      // todo
      keywords: [model.keywords],
      photo: photoUrls[0],
      photoSmall: photoUrls[1],
      symbols: [...model.symbols],
      sortProposals: {
        if (model.elements.isNotEmpty)
          user: Sort(id: user, user: user, elements: model.elements.values.flattened.toList(), voteBalance: 0, votes: []),
      },
      user: user,
      // todo
      addedDate: DateTime.now(),
    );
    return await ref.read(productRepositoryProvider).create(product);
  }
}
