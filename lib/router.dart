import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/bottom_bar_layout.dart';
import 'package:inzynierka/screens/init_screen.dart';

class RouterWrapper {
  static final routerDelegate = BeamerDelegate(
    initialPath: '/init',
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
    // without this 404 is opened from root beamer on hot reload
    updateParent: false,
    locationBuilder: RoutesLocationBuilder(
      routes: bottomNavigationRoutes,
    ),
  );
}
