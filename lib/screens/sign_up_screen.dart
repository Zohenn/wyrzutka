import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/services/auth_service.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/hooks/tap_gesture_recognizer.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/screens/sign_in_screen.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/utils/validators.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/progress_indicator_button.dart';

class SignUpModel {
  String name = '';
  String surname = '';
  String email = '';
  String password = '';
}

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useRef(GlobalKey<FormState>());
    final model = useRef(SignUpModel());
    final passwordVisible = useState(false);
    final isSigningUp = useState(false);
    final isSigningUpWithGoogle = useState(false);
    final signInGestureRecognizer = useTapGestureRecognizer(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        showDefaultBottomSheet(
          fullScreen: true,
          context: context,
          builder: (context) => SignInScreen(),
        );
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                'assets/images/access_account.svg',
                height: MediaQuery.of(context).size.height * 0.3,
              ),
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
                          'Rejestracja',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                label: Text('Imi??'),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => model.value.name = value.trim(),
                              validator: Validators.required('Uzupe??nij imi??'),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                label: Text('Nazwisko'),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => model.value.surname = value.trim(),
                              validator: Validators.required('Uzupe??nij nazwisko'),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          label: Text('Adres email'),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => model.value.email = value.trim(),
                        validator: Validators.required('Uzupe??nij adres email'),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: !passwordVisible.value,
                        decoration: InputDecoration(
                          label: Text('Has??o'),
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
                        validator: Validators.required('Uzupe??nij has??o'),
                      ),
                      ProgressIndicatorButton(
                        isLoading: isSigningUp.value,
                        onPressed: () async {
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }

                          isSigningUp.value = true;
                          await asyncCall(message: 'B????d rejestracji.', context, () async {
                            await ref.read(authServiceProvider).signUp(
                                  name: model.value.name,
                                  surname: model.value.surname,
                                  email: model.value.email,
                                  password: model.value.password,
                                );
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                          isSigningUp.value = false;
                        },
                        child: Center(child: Text('Zarejestruj si??')),
                      ),
                      Text('Lub', style: Theme.of(context).textTheme.labelLarge),
                      ProgressIndicatorButton(
                        isLoading: isSigningUpWithGoogle.value,
                        onPressed: () async {
                          isSigningUpWithGoogle.value = true;
                          await asyncCall(message: 'B????d rejestracji.', context, () async {
                            final user = await ref.read(authServiceProvider).signInWithGoogle();
                            if (user != null) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                          isSigningUpWithGoogle.value = false;
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
                            Text('Do????cz przez Google'),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Masz ju?? konto? '),
                            TextSpan(
                              text: 'Zaloguj si??',
                              recognizer: signInGestureRecognizer,
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
