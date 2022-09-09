import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';

SnackBar errorSnackBar({required BuildContext context, required String message}) => SnackBar(
  backgroundColor: AppColors.negativeDark,
  content: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, color: Colors.white),
      const SizedBox(width: 16.0),
      Flexible(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
        ),
      ),
    ],
  ),
);
