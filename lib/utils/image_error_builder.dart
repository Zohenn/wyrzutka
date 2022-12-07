import 'package:flutter/material.dart';
import 'package:wyrzutka/theme/colors.dart';

Widget imageErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) => const Tooltip(
      message: 'Zdjęcie niedostępne',
      child: Icon(
        Icons.error_outline,
        color: AppColors.negative,
      ),
    );
