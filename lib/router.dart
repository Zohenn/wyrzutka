import 'package:animations/animations.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/bottom_bar_layout.dart';
import 'package:inzynierka/screens/init_screen.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/screens/products_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/screens/profile_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';

wrapPage(Widget child, ValueKey key) => BeamPage(
      key: key,
      child: child,
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
  static WidgetRef? _ref;

  static init(WidgetRef ref) => _ref = ref;

  static final routerDelegate = BeamerDelegate(
    initialPath: '/init',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => const BottomBarLayout(),
        '/init': (context, state, data) => const InitScreen(),
        // '/login': (context, state, data) => const Scaffold(body: Center(child: Text('Login'))),
      },
    ),
  );

  static final bottomNavigationRoutes = {
    '/scan': (context, state, data) => wrapPage(const Scaffold(body: Center(child: Text('Skanuj'))), ValueKey('/scan')),
    '/products': (context, state, data) => wrapPage(const Scaffold(body: ProductsScreen()), ValueKey('/products')),
    '/profile': (context, state, data) =>
        wrapPage(const Scaffold(body: ProfileScreen()), ValueKey('/profile')),
    '/menu': (context, state, data) => wrapPage(const Scaffold(body: Center(child: Text('Menu'))), ValueKey('/menu')),
  };

  static final bottomNavigationRouterDelegate = BeamerDelegate(
    initialPath: '/scan',
    // without this 404 is opened from root beamer on hot reload
    updateParent: false,
    locationBuilder: RoutesLocationBuilder(
      routes: bottomNavigationRoutes,
    ),
    // xddd nice try
    // guards: [
    //   BeamGuard(
    //     pathPatterns: ['/profile'],
    //     check: (context, location) => _ref!.read(userProvider.notifier).state != null,
    //     onCheckFailed: (context, location) {
    //       showDefaultBottomSheet(context: context, builder: (context) => LoginScreen());
    //       // Beamer.of(context, root: true).beamToNamed('/login');
    //     },
    //   ),
    // ],
  );
}
