import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/hooks/tap_gesture_recognizer.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/password_recovery_screen.dart';
import 'package:inzynierka/screens/sign_up_screen.dart';
import 'package:inzynierka/utils/snackbars.dart';
import 'package:inzynierka/utils/firebase_errors.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

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
                        onChanged: (value) => model.value.email = value,
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
                            onChanged: (value) => model.value.password = value,
                            validator: Validators.required('Uzupełnij hasło'),
                          ),
                          // SizedBox(height: 6.0),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: Text('Zapomniałeś hasła?', style: Theme.of(context).textTheme.bodyMedium),
                          // ),
                        ],
                      ),
                      ProgressIndicatorButton(
                        isLoading: isSigningIn.value,
                        onPressed: () async {
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }
                          isSigningIn.value = true;
                          try {
                            await ref
                                .read(authServiceProvider)
                                .signIn(email: model.value.email, password: model.value.password);
                            Navigator.of(context, rootNavigator: true).pop();
                          } catch (e) {
                            final code = e is FirebaseException ? e.code : '';
                            ScaffoldMessenger.of(context).showSnackBar(
                              errorSnackBar(context: context, message: firebaseErrors[code] ?? 'Błąd logowania.'),
                            );
                          }
                          isSigningIn.value = false;
                        },
                        child: Center(child: Text('Zaloguj się')),
                      ),
                      Text('Lub', style: Theme.of(context).textTheme.labelLarge),
                      ProgressIndicatorButton(
                        isLoading: isSigningInWithGoogle.value,
                        onPressed: () async {
                          isSigningInWithGoogle.value = true;
                          try {
                            final user = await ref.read(authServiceProvider).signInWithGoogle();
                            if (user != null) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          } catch (e) {
                            final code = e is FirebaseException ? e.code : '';
                            ScaffoldMessenger.of(context).showSnackBar(
                              errorSnackBar(context: context, message: firebaseErrors[code] ?? 'Błąd logowania.'),
                            );
                          }
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
