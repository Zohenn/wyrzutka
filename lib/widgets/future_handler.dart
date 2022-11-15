import 'package:flutter/material.dart';
import 'package:inzynierka/theme/colors.dart';

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
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          debugPrintStack(stackTrace: snapshot.stackTrace);
          return error?.call(snapshot.error!) ??
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.primaryDarker, size: 48),
                      const SizedBox(height: 16.0),
                      Text(
                        'Ups... coś poszło nie tak',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'W trakcie ładowania zawartości wystąpił błąd, spróbuj ponownie później.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
        }

        switch (snapshot.connectionState) {
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
