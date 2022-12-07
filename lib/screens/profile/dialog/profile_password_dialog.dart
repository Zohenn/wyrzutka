import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/main.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:wyrzutka/services/auth_service.dart';
import 'package:wyrzutka/services/auth_user_service.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/snackbars.dart';
import 'package:wyrzutka/utils/validators.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class PasswordModel {
  String password = '';
  String newPassword = '';
}

class ProfilePasswordDialog extends HookConsumerWidget {
  const ProfilePasswordDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    final formKey = useRef(GlobalKey<FormState>());

    final passwordVisible = useState(false);
    final newPasswordVisible = useState(false);
    final model = useRef(PasswordModel());

    final isSaving = useState(false);

    return Dialog(
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey.value,
                  child: GutterColumn(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nowe hasło',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: !passwordVisible.value,
                        decoration: InputDecoration(
                          label: const Text('Stare hasło'),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                passwordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () => passwordVisible.value = !passwordVisible.value,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onChanged: (value) => model.value.password = value.trim(),
                        validator: Validators.required('Uzupełnij hasło'),
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: !newPasswordVisible.value,
                        decoration: InputDecoration(
                          label: const Text('Nowe hasło'),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                newPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () => newPasswordVisible.value = !newPasswordVisible.value,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onChanged: (value) => model.value.newPassword = value.trim(),
                        validator: Validators.required('Uzupełnij hasło'),
                      ),
                    ],
                  ),
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
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }

                          FocusManager.instance.primaryFocus?.unfocus();
                          ScaffoldMessenger.of(context).clearSnackBars();

                          isSaving.value = true;
                          await asyncCall(context, () async {
                            await authService.updatePassword(model.value.password, model.value.newPassword);
                            ScaffoldMessenger.of(rootScaffoldKey.currentContext!).showSnackBar(
                              successSnackBar(context: context, message: 'Hasło zostało zmienione'),
                            );
                            Navigator.of(context).pop();
                          });
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
