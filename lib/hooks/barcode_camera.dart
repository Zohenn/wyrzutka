import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

BarcodeCameraWrapper useBarcodeCamera({
  List<Object?>? keys,
}) {
  return use(
    const _BarcodeCameraHook(),
  );
}

class BarcodeCameraWrapper {
  final List<CameraDescription> _cameras = [];
  late final CameraController controller;
  final BarcodeScanner scanner = BarcodeScanner(formats: [BarcodeFormat.ean8, BarcodeFormat.ean13]);

  CameraDescription? get _backCamera => _cameras.firstWhereOrNull((element) => element.lensDirection == CameraLensDirection.back);

  Future<void> init() async {
    _cameras..clear()..addAll(await availableCameras());
    // todo: handle null
    controller = CameraController(_backCamera!, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
  }

  Future<Barcode?> scan() async {
    final picture = await controller.takePicture();
    await controller.pausePreview();
    final inputImage = InputImage.fromFilePath(picture.path);
    return (await scanner.processImage(inputImage)).firstOrNull;
  }

  void dispose() {
    scanner.close();
    controller.dispose();
  }
}

class _BarcodeCameraHook extends Hook<BarcodeCameraWrapper> {
  const _BarcodeCameraHook({
    List<Object?>? keys,
  }) : super(keys: keys);

  @override
  HookState<BarcodeCameraWrapper, Hook<BarcodeCameraWrapper>> createState() => _BarcodeCameraHookState();
}

class _BarcodeCameraHookState extends HookState<BarcodeCameraWrapper, _BarcodeCameraHook> {
  final camera = BarcodeCameraWrapper();

  @override
  BarcodeCameraWrapper build(BuildContext context) => camera;

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}