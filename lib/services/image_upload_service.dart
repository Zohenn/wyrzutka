import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';

final imageUploadServiceProvider = Provider(ImageUploadService.new);

class ImageUploadService {
  ImageUploadService(this.ref);

  final Ref ref;

  Future<String> uploadWithFile(File file, String path, {int width = 1920, int height = 1080}) async {
    final data = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: width,
      minHeight: height,
      format: CompressFormat.png,
      quality: 50,
    );
    if (data == null) {
      throw Exception('Could not compress image');
    }
    final imageRef = ref.read(firebaseStorageProvider).ref(path);
    final result = await imageRef.putData(data);
    return await result.ref.getDownloadURL();
  }
}
