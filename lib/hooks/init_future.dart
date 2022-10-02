import 'package:flutter_hooks/flutter_hooks.dart';

Future<T> useInitFuture<T>(Future<T> Function() action) {
  final future = useState<Future<T>?>(null);
  useEffect(() {
    future.value = action();
    return null;
  }, []);
  return future.value!;
}