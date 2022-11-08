import 'package:animations/animations.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/screens/bottom_bar_layout.dart';
import 'package:inzynierka/screens/init_screen.dart';
import 'package:inzynierka/screens/scanner_screen.dart';
import 'package:inzynierka/screens/products_screen.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';

wrapPage(Widget child, ValueKey key) => BeamPage(
      key: key,
      child: Scaffold(body: child),
      routeBuilder: (BuildContext context, RouteSettings settings, Widget child) => PageRouteBuilder(
        settings: settings,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
          fillColor: Colors.white,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        pageBuilder: (_, __, ___) => child,
      ),
    );

class RouterWrapper {
  static final routerDelegate = BeamerDelegate(
    initialPath: '/init',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => const BottomBarLayout(),
        '/init': (context, state, data) => const InitScreen(),
      },
    ),
  );

  static final bottomNavigationRoutes = {
    '/scan': (context, state, data) => wrapPage(const ScannerScreen(), const ValueKey('/scan')),
    '/products': (context, state, data) => wrapPage(const ProductsScreen(), const ValueKey('/products')),
    '/profile': (context, state, data) => wrapPage(const ProfileScreen(), const ValueKey('/profile')),
    '/menu': (context, state, data) => wrapPage(const Center(child: Text('Menu')), const ValueKey('/menu')),
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
