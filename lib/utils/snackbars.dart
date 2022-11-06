import 'package:flutter/material.dart';
import 'package:inzynierka/theme/colors.dart';

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
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

SnackBar successSnackBar({required BuildContext context, required String message}) => SnackBar(
      backgroundColor: AppColors.positive,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 16.0),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
