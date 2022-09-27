import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart';

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
  BarcodeCameraWrapper({this.onInit});

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
    final image = decodeImage(await picture.readAsBytes())!;
    final offsetX = (image.width * 0.15).toInt();
    final offsetY = (image.height * 0.15).toInt();
    final croppedImage = copyCrop(image, offsetX, offsetY, (image.width * 0.7).toInt(), (image.height * 0.2).toInt());
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
    final offsetX = (image.width * 0.15).toInt();
    final offsetY = (image.height * 0.15).toInt();
    final croppedImage = copyCrop(image, offsetX, offsetY, (image.width * 0.7).toInt(), (image.height * 0.2).toInt());
    return Uint8List.fromList(encodeJpg(croppedImage));
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
  late final camera = BarcodeCameraWrapper(onInit: () => setState(() {}));

  @override
  BarcodeCameraWrapper build(BuildContext context) => camera;

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}
