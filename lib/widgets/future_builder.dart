import 'package:flutter/material.dart';

class FutureHandler<T> extends StatelessWidget {
  const FutureHandler({
    Key? key,
    required this.future,
    required this.data,
  }) : super(key: key);

  final Future<T>? future;
  final Widget Function() data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Center(child: Text(snapshot.error.toString()));
        }

        switch(snapshot.connectionState){
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Center(child: const CircularProgressIndicator());
          case ConnectionState.none:
          case ConnectionState.done:
          return data();
        }
      },
    );
  }
}
