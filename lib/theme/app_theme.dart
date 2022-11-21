import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inzynierka/theme/color_schemes.dart';
import 'package:inzynierka/theme/colors.dart';

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
          filled: true,
          fillColor: Colors.white,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xffE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.negative),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          // contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        ),
        textTheme: TextTheme(
          labelSmall: TextStyle(color: lightColorScheme.outline),
          bodySmall: TextStyle(color: lightColorScheme.outline),
        ),
        cardTheme: CardTheme(
          color: AppColors.gray,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide.none,
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
        ),
        cardColor: AppColors.gray,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            disabledForegroundColor: Colors.black45,
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.gray,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ).copyWith(elevation: const MaterialStatePropertyAll(0)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            disabledForegroundColor: Colors.black45,
            backgroundColor: Colors.white,
            disabledBackgroundColor: AppColors.gray,
            elevation: 0,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide.none,
          ),
        ),
        dividerTheme: const DividerThemeData(
          thickness: 1,
          color: Color(0xffE0E0E0),
        ),
        disabledColor: const Color(0xffE0E0E0),
      ),
      child: child,
    );
  }
}
