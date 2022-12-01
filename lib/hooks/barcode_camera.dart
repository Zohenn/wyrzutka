import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart';

BarcodeCamera useBarcodeCamera({
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

class BarcodeCamera {
  BarcodeCamera._({this.onInit});

  static const scanAreaOffsetFactor = 0.15;
  static const scanAreaWidthFactor = 0.7;
  static const scanAreaHeightFactor = 0.2;

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
    scanner = BarcodeScanner(
      formats: [BarcodeFormat.ean8, BarcodeFormat.ean13],
    );
    _cameras
      ..clear()
      ..addAll(await availableCameras());
    controller = CameraController(
      _backCamera!,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  Future<Barcode?> scan() async {
    final picture = await controller!.takePicture();
    await controller!.pausePreview();
    final image = decodeImage(await picture.readAsBytes())!;

    final offsetX = (image.width * scanAreaOffsetFactor).toInt();
    final offsetY = (image.height * scanAreaOffsetFactor).toInt();
    final width = (image.width * scanAreaWidthFactor).toInt();
    final height = (image.height * scanAreaHeightFactor).toInt();

    final croppedImage = copyCrop(image, offsetX, offsetY, width, height);
    final pictureFile = File(picture.path);
    pictureFile.writeAsBytesSync(encodeJpg(croppedImage));
    final inputImage = InputImage.fromFilePath(picture.path);

    final barcode = (await scanner!.processImage(inputImage)).firstOrNull;
    pictureFile.delete();
    return barcode;
  }

  Future<Uint8List> cropTest() async {
    final picture = await controller!.takePicture();
    // await controller!.pausePreview();
    final image = decodeImage(await picture.readAsBytes())!;
    final offsetX = (image.width * scanAreaOffsetFactor).toInt();
    final offsetY = (image.height * scanAreaOffsetFactor).toInt();
    final width = (image.width * scanAreaWidthFactor).toInt();
    final height = (image.height * scanAreaHeightFactor).toInt();

    final croppedImage = copyCrop(image, offsetX, offsetY, width, height);
    return Uint8List.fromList(encodeJpg(croppedImage));
  }

  void dispose() {
    scanner?.close();
    controller?.dispose();
    _initFuture = null;
  }
}

class _BarcodeCameraHook extends Hook<BarcodeCamera> {
  const _BarcodeCameraHook({
    List<Object?>? keys,
  }) : super(keys: keys);

  @override
  HookState<BarcodeCamera, Hook<BarcodeCamera>> createState() => _BarcodeCameraHookState();
}

class _BarcodeCameraHookState extends HookState<BarcodeCamera, _BarcodeCameraHook> {
  late final camera = BarcodeCamera._(onInit: () => setState(() {}));

  @override
  BarcodeCamera build(BuildContext context) => camera;

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}
