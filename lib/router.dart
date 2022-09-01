import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/bottom_bar_layout.dart';
import 'package:inzynierka/main.dart';
import 'package:inzynierka/screens/init_screen.dart';

class RouterWrapper {
  static final routerDelegate = BeamerDelegate(
    initialPath: '/init',
    routeListener: (_, __) {
      print(_.location);
      print(__);
    },
    locationBuilder: RoutesLocationBuilder(routes: {
      '/': (context, state, data) => const BottomBarLayout(),
      '/init': (context, state, data) => const InitScreen(),
    },),
  );

  static final bottomNavigationRoutes = {
    '/scan': (context, state, data) => const Scaffold(body: Center(child: Text('Skanuj'))),
    '/products': (context, state, data) => const Scaffold(body: Center(child: Text('Produkty'))),
    '/profile': (context, state, data) => const Scaffold(body: Center(child: Text('Profil'))),
    '/menu': (context, state, data) => const Scaffold(body: Center(child: Text('Menu'))),
  };

  static final bottomNavigationRouterDelegate = BeamerDelegate(
    initialPath: '/scan',
    routeListener: (_, __) {
      print(_.location);
      print(__);
    },
    locationBuilder: RoutesLocationBuilder(
      routes: bottomNavigationRoutes,
    ),
  );
}
