import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/main.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/snackbars.dart';
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

    final availableRoles = Role.values.where((element) => element.index <= authUser!.role.index);
    final selectedRole = useState(user.role);
    final isSaving = useState(false);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Zmiana roli', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16.0),
                  Column(
                    children: [
                      Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        user.role.desc,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: user.role.descColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  DropdownButtonFormField<Role>(
                    key: const ValueKey('Dropdown'),
                    value: selectedRole.value,
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    decoration: const InputDecoration(labelText: 'Nowa rola'),
                    items: [
                      for (var role in availableRoles)
                        DropdownMenuItem(
                          key: ValueKey(role.desc),
                          value: role,
                          child: Text(role.desc, style: TextStyle(color: role.descColor)),
                        ),
                    ],
                    onChanged: (newRole) => selectedRole.value = newRole!,
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
                        await asyncCall(context, () async {
                          await userService.changeRole(user, selectedRole.value);
                          ScaffoldMessenger.of(rootScaffoldKey.currentContext!).showSnackBar(
                            successSnackBar(context: context, message: 'Rola została zmieniona'),
                          );
                          Navigator.of(context).pop();
                        });
                        isSaving.value = false;
                      },
                      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        foregroundColor: const MaterialStatePropertyAll(Colors.white),
                        backgroundColor: const MaterialStatePropertyAll(AppColors.primaryDarker),
                      ),
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
