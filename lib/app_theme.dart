import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        // textTheme: GoogleFonts.notoSansTextTheme(
        //   TextTheme(labelSmall: TextStyle(color: lightColorScheme.outline)),
        // ),
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
        ),
        cardColor: AppColors.gray,
        scaffoldBackgroundColor: Colors.white,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: AppColors.primary,
            //createMaterialColor(AppColors.primary).shade50,
            elevation: 0,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide.none,
          ),
        ),
        dividerTheme: DividerThemeData(
          thickness: 1,
          color: Color(0xffE0E0E0),
        ),
        disabledColor: Color(0xffE0E0E0),
      ),
      child: child,
    );
  }
}
