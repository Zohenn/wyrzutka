import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/routing/router.dart';

final _innerBeamerKey = GlobalKey<BeamerState>();

final _menuIndexProvider = StateProvider((ref) => 0);

class BottomBarLayout extends HookConsumerWidget {
  const BottomBarLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Beamer(
        key: _innerBeamerKey,
        routerDelegate: RouterWrapper.bottomNavigationRouterDelegate,
        backButtonDispatcher: BeamerBackButtonDispatcher(delegate: RouterWrapper.bottomNavigationRouterDelegate),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        onDestinationSelected: (index) {
          _innerBeamerKey.currentState!.routerDelegate.beamToReplacementNamed(
            RouterWrapper.bottomNavigationRoutes.keys.elementAt(index).toString(),
          );
          ref.read(_menuIndexProvider.notifier).state = index;
        },
        selectedIndex: ref.watch(_menuIndexProvider),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.crop_free),
            label: 'Skanuj',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produkty',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Użytkownicy',
          ),
        ],
      ),
    );
  }
}
