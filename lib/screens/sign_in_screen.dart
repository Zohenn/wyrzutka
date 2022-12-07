import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/services/auth_service.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/hooks/tap_gesture_recognizer.dart';
import 'package:wyrzutka/screens/password_recovery_screen.dart';
import 'package:wyrzutka/screens/sign_up_screen.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/utils/validators.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class SignInModel {
  String email = '';
  String password = '';
}

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({Key? key}) : super(key: key);

  void openSignUp(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    showDefaultBottomSheet(
      fullScreen: true,
      context: context,
      builder: (context) => SignUpScreen(),
    );
  }

  void openPasswordRecovery(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    showDefaultBottomSheet(
      fullScreen: true,
      context: context,
      builder: (context) => PasswordRecoveryScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useRef(GlobalKey<FormState>());
    final model = useRef(SignInModel());
    final passwordVisible = useState(false);
    final isSigningIn = useState(false);
    final isSigningInWithGoogle = useState(false);
    final signUpGestureRecognizer = useTapGestureRecognizer(onTap: () => openSignUp(context));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset('assets/images/throw_away.svg', height: MediaQuery.of(context).size.height * 0.3),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Form(
              key: formKey.value,
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GutterColumn(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Logowanie',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          label: Text('Adres email'),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => model.value.email = value.trim(),
                        validator: Validators.required('Uzupełnij adres email'),
                      ),
                      Column(
                        children: [
                          TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            obscureText: !passwordVisible.value,
                            decoration: InputDecoration(
                              label: Text('Hasło'),
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
                              counter: GestureDetector(
                                onTap: () => openPasswordRecovery(context),
                                child: Text('Zapomniałeś hasła?', style: Theme.of(context).textTheme.labelMedium),
                              ),
                            ),
                            onChanged: (value) => model.value.password = value.trim(),
                            validator: Validators.required('Uzupełnij hasło'),
                          ),
                        ],
                      ),
                      ProgressIndicatorButton(
                        isLoading: isSigningIn.value,
                        onPressed: () async {
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }
                          isSigningIn.value = true;
                          await asyncCall(message: 'Błąd logowania.', context, () async {
                            await ref
                                .read(authServiceProvider)
                                .signIn(email: model.value.email, password: model.value.password);
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                          isSigningIn.value = false;
                        },
                        child: Center(child: Text('Zaloguj się')),
                      ),
                      Text('Lub', style: Theme.of(context).textTheme.labelLarge),
                      ProgressIndicatorButton(
                        isLoading: isSigningInWithGoogle.value,
                        onPressed: () async {
                          isSigningInWithGoogle.value = true;
                          await asyncCall(message: 'Błąd logowania.', context, () async {
                            final user = await ref.read(authServiceProvider).signInWithGoogle();
                            if (user != null) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                          isSigningInWithGoogle.value = false;
                        },
                        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
                              backgroundColor: MaterialStatePropertyAll(Colors.white),
                              side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/google_logo.svg',
                              width: 24,
                              height: 24,
                            ),
                            // Icon(Icons.circle),
                            SizedBox(width: 12.0),
                            Text('Zaloguj się przez Google'),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Nie masz konta? ',
                            ),
                            TextSpan(
                              text: 'Zarejestruj się',
                              recognizer: signUpGestureRecognizer,
                              style: TextStyle(color: AppColors.primaryDarker),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
