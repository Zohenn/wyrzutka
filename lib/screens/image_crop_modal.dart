import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image/image.dart' as image_x;
import 'package:inzynierka/colors.dart';
import 'package:supercharged/supercharged.dart';

class ImageCropModal extends HookWidget {
  const ImageCropModal({
    Key? key,
    required this.image,
  }) : super(key: key);

  final File image;

  Size? widgetSize(GlobalKey key) => (key.currentContext?.findRenderObject() as RenderBox?)?.size;

  Future<void> cropImage(BuildContext context, Offset offset, Size size, double scale) async {
    final _image = image_x.decodeImage(await image.readAsBytes())!;
    final imageSize = Size(_image.width.toDouble(), _image.height.toDouble());
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final actualSize = size * pixelRatio / scale;
    final offsetX = ((imageSize.width - actualSize.width) / 2 - offset.dx * pixelRatio / scale).toInt();
    final offsetY = ((imageSize.height - actualSize.height) / 2 - offset.dy * pixelRatio / scale).toInt();
    final croppedImage =
        image_x.copyCrop(_image, offsetX, offsetY, actualSize.width.ceil().toInt(), actualSize.height.ceil().toInt());
    // best line of code ever written
    final imageFile = File(image.path.reverse.replaceFirst('.', '_cropped.'.reverse).reverse);
    await imageFile.create();
    await imageFile.writeAsBytes(image_x.encodeNamedImage(croppedImage, imageFile.path)!);
    Navigator.of(context).pop(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    final decodedImage = useRef<image_x.Image?>(null);
    final imageKey = useRef(GlobalKey());
    final frameKey = useRef(GlobalKey());
    final fitScale = useRef(0.0);
    final imageOffset = useValueNotifier(const Offset(0.0, 0.0));

    useEffect(() {
      (() async {
        decodedImage.value = image_x.decodeImage(await image.readAsBytes());
        final frameSize = widgetSize(frameKey.value);
        if (frameSize != null) {
          final scale =
              frameSize.width * MediaQuery.of(context).devicePixelRatio / decodedImage.value!.width.toDouble();
          fitScale.value = scale;
        }
      })();
      return null;
    }, []);

    const frameOutside = Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white38),
        child: Center(),
      ),
    );

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).dividerColor),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  key: imageKey.value,
                  children: [
                    Positioned.fill(
                      child: ValueListenableBuilder(
                        valueListenable: imageOffset,
                        builder: (context, value, child) => Transform.translate(
                          offset: imageOffset.value,
                          child: child,
                        ),
                        child: Image.file(File(image.path), fit: BoxFit.fitWidth),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          frameOutside,
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: DecoratedBox(
                              key: frameKey.value,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryDarker, width: 3),
                              ),
                            ),
                          ),
                          frameOutside,
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final frameSize = widgetSize(frameKey.value);
                          if (decodedImage.value != null && frameSize != null) {
                            Size imageSize =
                                Size(decodedImage.value!.width.toDouble(), decodedImage.value!.height.toDouble()) /
                                    MediaQuery.of(context).devicePixelRatio;
                            imageSize *= fitScale.value;
                            final maxExtentX = (imageSize.width - frameSize.width) / 2;
                            final maxExtentY = (imageSize.height - frameSize.height) / 2;
                            final offset = imageOffset.value;
                            print(frameSize);
                            print(imageSize);
                            print(maxExtentX);
                            print(maxExtentY);
                            imageOffset.value = Offset(
                              (offset.dx + details.delta.dx).clamp(-maxExtentX, maxExtentX),
                              (offset.dy + details.delta.dy).clamp(-maxExtentY, maxExtentY),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Przesuń zdjęcie tak, aby produkt zmieścił się w wyznaczonym kwadracie.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () => cropImage(context, imageOffset.value, widgetSize(frameKey.value)!, fitScale.value),
                  child: const Center(
                    child: Text('Przytnij zdjęcie'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
