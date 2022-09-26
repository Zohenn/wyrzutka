import 'package:flutter/material.dart';

class FutureHandler<T> extends StatelessWidget {
  const FutureHandler({
    Key? key,
    required this.future,
    this.loading,
    required this.data,
  }) : super(key: key);

  final Future<T>? future;
  final Widget Function()? loading;
  final Widget Function() data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          debugPrint(snapshot.error.toString());
          debugPrintStack(stackTrace: snapshot.stackTrace);
          return Center(child: Text(snapshot.error.toString()));
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
