import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

TapGestureRecognizer useTapGestureRecognizer({
  VoidCallback? onTap,
  List<Object?>? keys,
}) {
  return use(
    _TapGestureRecognizerHook(onTap: onTap),
  );
}

class _TapGestureRecognizerHook extends Hook<TapGestureRecognizer> {
  const _TapGestureRecognizerHook({
    required this.onTap,
    List<Object?>? keys,
  }) : super(keys: keys);

  final VoidCallback? onTap;

  @override
  HookState<TapGestureRecognizer, Hook<TapGestureRecognizer>> createState() => _TapGestureRecognizerHookState();
}

class _TapGestureRecognizerHookState extends HookState<TapGestureRecognizer, _TapGestureRecognizerHook> {
  late final recognizer = TapGestureRecognizer()..onTap = hook.onTap;

  @override
  TapGestureRecognizer build(BuildContext context) => recognizer;

  @override
  void dispose() => recognizer.dispose();

  @override
  String get debugLabel => 'useTapGestureRecognizer';
}