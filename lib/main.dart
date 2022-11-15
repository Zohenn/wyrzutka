import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inzynierka/theme/app_theme.dart';
import 'package:inzynierka/routing/router.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pl';

  runApp(
    const ProviderScope(
      child: AppTheme(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: Theme.of(context),
      routeInformationParser: BeamerParser(),
      routerDelegate: RouterWrapper.routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: RouterWrapper.routerDelegate),
      builder: (context, child) => Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          },
          child: child,
        ),
      ),
      localizationsDelegates: const [...GlobalMaterialLocalizations.delegates],
      locale: const Locale('pl'),
      supportedLocales: const [Locale('en'), Locale('pl')],
    );
  }
}
