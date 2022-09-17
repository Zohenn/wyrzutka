import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef DebounceOnChanged = void Function(dynamic value);
typedef DebounceEmit = void Function(dynamic value);

DebounceOnChanged useDebounceHook({
  required DebounceEmit onEmit,
  Duration duration = const Duration(milliseconds: 500),
  List<Object?>? keys,
}) {
  return use(
    _DebounceHook(onEmit: onEmit, duration: duration, keys: keys),
  );
}

class _DebounceHook extends Hook<DebounceOnChanged> {
  const _DebounceHook({
    required this.onEmit,
    required this.duration,
    List<Object?>? keys,
  }) : super(keys: keys);

  final DebounceEmit onEmit;
  final Duration duration;

  @override
  HookState<DebounceOnChanged, Hook<DebounceOnChanged>> createState() => _DebounceHookState();
}

class _DebounceHookState extends HookState<DebounceOnChanged, _DebounceHook> {
  Timer? timer;

  void onChanged(dynamic value) {
    if (timer?.isActive == true) {
      timer?.cancel();
    }

    timer = Timer(hook.duration, () {
      hook.onEmit(value);
    });
  }

  @override
  DebounceOnChanged build(BuildContext context) => onChanged;

  @override
  void dispose() => timer?.cancel();

  @override
  String get debugLabel => 'useDebounceHook';
}