import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  NavigatorState? get navigator => _navigator;

  NavigatorState? _navigator;

  @override
  void didPush(Route? route, Route? previousRoute) => super.noSuchMethod(
    Invocation.method(#didpush, [route, previousRoute]),
  );

  @override
  void didPop(Route? route, Route? previousRoute) => super.noSuchMethod(
    Invocation.method(#didPop, [route, previousRoute]),
  );

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => super.noSuchMethod(
    Invocation.method(#didReplace, null, {#newRoute: newRoute, #oldRoute: oldRoute}),
  );
}