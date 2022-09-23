import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';

Widget imageErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) => const Tooltip(
      message: 'Zdjęcie niedostępne',
      child: Icon(
        Icons.error_outline,
        color: AppColors.negative,
      ),
    );
