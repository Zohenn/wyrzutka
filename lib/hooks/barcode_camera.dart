import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

BarcodeCameraWrapper useBarcodeCamera({
  List<Object?>? keys,
}) {
  final camera = use(
    const _BarcodeCameraHook(),
  );
  useAppLifecycleState();
  useOnAppLifecycleStateChange((previous, current) {
    switch (current) {
      case AppLifecycleState.resumed:
        camera.initFuture;
        break;
      case AppLifecycleState.paused:
        camera.dispose();
        break;
      default:
        break;
    }
  });
  return camera;
}

class BarcodeCameraWrapper {
  BarcodeCameraWrapper({ this.onInit });

  final List<CameraDescription> _cameras = [];
  CameraController? controller;
  BarcodeScanner? scanner;
  Future<void>? _initFuture;

  final void Function()? onInit;

  Future<void> get initFuture {
    _initFuture ??= init();
    return _initFuture!;
  }

  CameraDescription? get _backCamera =>
      _cameras.firstWhereOrNull((element) => element.lensDirection == CameraLensDirection.back);

  Future<void> init() async {
    onInit?.call();
    scanner = BarcodeScanner(formats: [BarcodeFormat.ean8, BarcodeFormat.ean13]);
    _cameras
      ..clear()
      ..addAll(await availableCameras());
    controller = CameraController(_backCamera!, ResolutionPreset.high, enableAudio: false);
    await controller!.initialize();
  }

  Future<Barcode?> scan() async {
    final picture = await controller!.takePicture();
    await controller!.pausePreview();
    final inputImage = InputImage.fromFilePath(picture.path);
    return (await scanner!.processImage(inputImage)).firstOrNull;
  }

  void dispose() {
    scanner?.close();
    controller?.dispose();
    _initFuture = null;
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
  late final camera = BarcodeCameraWrapper(onInit: () => setState((){}));

  @override
  BarcodeCameraWrapper build(BuildContext context) => camera;

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}
