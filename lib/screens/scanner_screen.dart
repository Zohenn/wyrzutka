import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wyrzutka/hooks/barcode_camera.dart';
import 'package:wyrzutka/screens/scanner_product_modal.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/gutter_row.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class ScannerAreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect background = Rect.fromLTWH(0, 0, size.width, size.height);
    var backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Rect box = Rect.fromLTWH(
      size.width * BarcodeCamera.scanAreaOffsetFactor,
      size.height * BarcodeCamera.scanAreaOffsetFactor,
      size.width * BarcodeCamera.scanAreaWidthFactor,
      size.height * BarcodeCamera.scanAreaHeightFactor,
    );
    var boxPaint = Paint()..blendMode = BlendMode.clear;
    canvas
      ..saveLayer(null, Paint())
      ..drawRect(background, backgroundPaint)
      ..drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(18)), boxPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScannerScreen extends HookWidget {
  const ScannerScreen({
    Key? key,
  }) : super(key: key);

  FutureOr<void> showProductModal(BuildContext context, String id) {
    if (id != '') {
      return showDefaultBottomSheet(
        context: context,
        builder: (context) => DefaultBottomSheet(
          child: ScannerProductModal(id: id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: GutterRow(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                Flexible(
                  child: Text('Nie znaleziono kodu kreskowego'),
                ),
              ],
            ),
          ),
        );
    }
  }

  bool isPermissionError(Object error) {
    return error is CameraException && error.code == 'CameraAccessDenied';
  }

  String errorText(Object error) {
    if (isPermissionError(error)) {
      return 'Zezw??l aplikacji na dost??p do kamery, aby m??c skorzysta?? ze skanera.';
    }

    return 'B????d przy inicjalizacji kamery.';
  }

  @override
  Widget build(BuildContext context) {
    final camera = useBarcodeCamera();
    final isScanning = useState(false);

    return SafeArea(
      child: FutureHandler(
        future: camera.initFuture,
        data: () => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: CameraPreview(camera.controller!)),
            Positioned.fill(
              child: CustomPaint(
                painter: ScannerAreaPainter(),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, 0.80),
              child: ProgressIndicatorButton(
                isLoading: isScanning.value,
                onPressed: () async {
                  isScanning.value = true;
                  await asyncCall(
                    context,
                    () async {
                      final value = await camera.scan();
                      isScanning.value = false;
                      await showProductModal(context, value?.rawValue ?? '');
                      camera.controller!.resumePreview();
                    },
                  );
                  isScanning.value = false;
                },
                child: const Text('Skanuj'),
              ),
            ),
          ],
        ),
        error: (error) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorText(error), textAlign: TextAlign.center),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    camera.dispose();
                    camera.initFuture;
                  },
                  child: const Text('Spr??buj ponownie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
