import 'package:flutter/material.dart';

class FutureHandler<T> extends StatelessWidget {
  const FutureHandler({
    Key? key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  }) : super(key: key);

  final Future<T>? future;
  final Widget Function() data;
  final Widget Function()? loading;
  final Widget Function(Object error)? error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          debugPrint(snapshot.error.toString());
          debugPrintStack(stackTrace: snapshot.stackTrace);
          return error?.call(snapshot.error!) ?? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(snapshot.error.toString())),
          );
        }

        switch(snapshot.connectionState){
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loading?.call() ?? const Center(child: CircularProgressIndicator());
          case ConnectionState.none:
          case ConnectionState.done:
          return data();
        }
      },
    );
  }
}
