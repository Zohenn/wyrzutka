import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/snackbars.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class PasswordRecoveryScreen extends HookConsumerWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  void openSignIn(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    showDefaultBottomSheet(
      fullScreen: true,
      context: context,
      builder: (context) => SignInScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useRef(GlobalKey<FormState>());
    final email = useRef('');
    final isSendingEmail = useState(false);

    return Scaffold(
      body: CustomScrollView(
        reverse: true,
        slivers: [
          SliverToBoxAdapter(
            child: Form(
              key: formKey.value,
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GutterColumn(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Zapomniałeś hasła?',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pomożemy Ci! Potrzebujemy tylko adresu email powiązanego z Twoim kontem.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Theme.of(context).textTheme.labelSmall!.color),
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          label: Text('Adres email'),
                        ),
                        onChanged: (value) => email.value = value,
                        validator: Validators.required('Uzupełnij adres email'),
                      ),
                      ProgressIndicatorButton(
                        isLoading: isSendingEmail.value,
                        onPressed: () async {
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }
                          isSendingEmail.value = true;
                          await asyncCall(
                            message: 'W trakcie wysyłania wystąpił błąd.',
                            context,
                            () async {
                              await ref.read(authServiceProvider).sendPasswordResetEmail(email.value);
                              openSignIn(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                successSnackBar(
                                    context: context, message: 'Wiadomość wysłana, sprawdź skrzynkę pocztową.'),
                              );
                            },
                          );
                          isSendingEmail.value = false;
                        },
                        child: Center(child: Text('Wyślij instrukcje')),
                      ),
                      GestureDetector(
                        onTap: () => openSignIn(context),
                        child: Text(
                          'Powrót do logowania',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryDarker),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset('assets/images/forgot_password.svg',
                  height: MediaQuery.of(context).size.height * 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
