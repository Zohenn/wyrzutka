import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/main.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/services/auth_user_service.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/snackbars.dart';
import 'package:wyrzutka/utils/validators.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class UserModel {
  UserModel(this.name, this.surname);

  factory UserModel.fromUser(AppUser user) => UserModel(
        user.name,
        user.surname,
      );

  String name;
  String surname;
}

class ProfileUserInfoDialog extends HookConsumerWidget {
  const ProfileUserInfoDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserService = ref.read(authUserServiceProvider);
    final formKey = useRef(GlobalKey<FormState>());

    final model = useRef(UserModel.fromUser(user));
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
                        'Dane konta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextFormField(
                      initialValue: model.value.name,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        label: Text('Imi??'),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      onChanged: (value) => model.value.name = value.trim(),
                      validator: Validators.required('Uzupe??nij imi??'),
                    ),
                    TextFormField(
                      initialValue: model.value.surname,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        label: Text('Nazwisko'),
                      ),
                      keyboardType: TextInputType.name,
                      onChanged: (value) => model.value.surname = value.trim(),
                      validator: Validators.required('Uzupe??nij nazwisko'),
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
                          await authUserService.changeInfo(model.value.name, model.value.surname);
                          ScaffoldMessenger.of(rootScaffoldKey.currentContext!).showSnackBar(
                            successSnackBar(context: context, message: 'Dane zosta??y zmienione'),
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
