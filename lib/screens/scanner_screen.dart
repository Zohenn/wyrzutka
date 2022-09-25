import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/screens/widgets/scanner_product_modal.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScannerController useScannerController({
  List<Object?>? keys,
}) {
  return use(
    const _ScannerControllerHook(),
  );
}

class _ScannerControllerHook extends Hook<MobileScannerController> {
  const _ScannerControllerHook({
    List<Object?>? keys,
  }) : super(keys: keys);

  @override
  HookState<MobileScannerController, Hook<MobileScannerController>> createState() => _ScannerControllerHookState();
}

class _ScannerControllerHookState extends HookState<MobileScannerController, _ScannerControllerHook> {
  late final controller = MobileScannerController();

  @override
  MobileScannerController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useScannerController';
}

class ScannerAreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect background = Rect.fromLTWH(0, 0, size.width, size.height);
    var backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Rect box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 4),
      width: size.width * 0.7,
      height: size.width * 0.3,
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

  void showProductModal(BuildContext context, String id) {
    if (id != '') {
      showDefaultBottomSheet(
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
                  child: Text("Nie znaleziono kodu kreskowego"),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = useScannerController();
    final code = useState('485769');
    return Stack(
      children: [
        MobileScanner(
          allowDuplicates: false,
          controller: cameraController,
          onDetect: (barcode, args) {
            if (barcode.rawValue == null) {
              code.value = '';
              debugPrint('Failed to scan Barcode');
            } else {
              code.value = barcode.rawValue!;
              debugPrint('Barcode found! ${code.value}');
            }
          },
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ScannerAreaPainter(),
          ),
        ),
        GutterColumn(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GutterRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showProductModal(context, code.value);
                  },
                  child: const Text('Skanuj'),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.07),
          ],
        ),
      ],
    );
  }
}
