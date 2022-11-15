import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/main.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/services/auth_user_service.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/snackbars.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class ProfileRoleDialog extends HookConsumerWidget {
  const ProfileRoleDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);

    final role = useState(user.role);
    final isSaving = useState(false);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GutterColumn(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rola użytkownika',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  DropdownButton(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 42,
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    value: role.value,
                    items: Role.values.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value.desc, style: TextStyle(color: value.descColor)),
                      );
                    }).toList(),
                    onChanged: (Role? newRole) => role.value = newRole!,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Anuluj'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ProgressIndicatorButton(
                      isLoading: isSaving.value,
                      onPressed: () async {
                        final userService = ref.read(userServiceProvider);

                        FocusManager.instance.primaryFocus?.unfocus();
                        ScaffoldMessenger.of(context).clearSnackBars();

                        isSaving.value = true;
                        await asyncCall(context, () => userService.changeRole(user, role.value));
                        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                          successSnackBar(context: context, message: 'Rola została zmieniona'),
                        );
                        Navigator.of(context).pop();
                        isSaving.value = false;
                      },
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: AppColors.primaryDarker),
                      child: const Text('Zapisz'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
