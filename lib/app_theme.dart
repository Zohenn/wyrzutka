import 'package:flutter/material.dart';
import 'package:inzynierka/color_schemes.g.dart';
import 'package:inzynierka/colors.dart';

class AppTheme extends StatelessWidget {
  const AppTheme({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        platform: TargetPlatform.android,
        primarySwatch: createMaterialColor(AppColors.primary),
        // colorScheme: lightColorScheme,
        // colorSchemeSeed: AppColors.primary,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        ),
        textTheme: TextTheme(
          labelSmall: TextStyle(color: lightColorScheme.outline),
        ),
        cardTheme: CardTheme(
          color: AppColors.gray,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide.none,
          ),
          margin: EdgeInsets.zero,
        ),
        cardColor: AppColors.gray,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: AppColors.primary, //createMaterialColor(AppColors.primary).shade50,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
        ),
      ),
      child: child,
    );
  }
}
