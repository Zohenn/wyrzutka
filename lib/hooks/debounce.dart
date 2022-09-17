import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef DebounceOnChanged<T> = void Function(T value);
typedef DebounceEmit<T> = void Function(T value);

Debounce<T> useDebounceHook<T>({
  required DebounceEmit onEmit,
  Duration duration = const Duration(milliseconds: 500),
  List<Object?>? keys,
}) {
  return use(
    _DebounceHook<T>(onEmit: onEmit, duration: duration, keys: keys),
  );
}

class Debounce<T> {
  const Debounce({ required this.onChanged, required this.cancel });

  final DebounceOnChanged<T> onChanged;
  final VoidCallback cancel;
}

class _DebounceHook<T> extends Hook<Debounce<T>> {
  const _DebounceHook({
    required this.onEmit,
    required this.duration,
    List<Object?>? keys,
  }) : super(keys: keys);

  final DebounceEmit onEmit;
  final Duration duration;

  @override
  HookState<Debounce<T>, Hook<Debounce<T>>> createState() => _DebounceHookState<T>();
}

class _DebounceHookState<T> extends HookState<Debounce<T>, _DebounceHook<T>> {
  late final Debounce<T> debounce = Debounce(onChanged: onChanged, cancel: cancel);
  Timer? timer;

  void onChanged(dynamic value) {
    if (timer?.isActive == true) {
      timer?.cancel();
    }

    timer = Timer(hook.duration, () {
      hook.onEmit(value);
    });
  }

  void cancel() {
    timer?.cancel();
  }

  @override
  Debounce<T> build(BuildContext context) => debounce;

  @override
  void dispose() => timer?.cancel();

  @override
  String get debugLabel => 'useDebounceHook';
}