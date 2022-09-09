import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/hooks/tap_gesture_recognizer.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/sign_up_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useState('');
    final password = useState('');
    final passwordVisible = useState(false);
    final signUpGestureRecognizer = useTapGestureRecognizer(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        showDefaultBottomSheet(
          fullScreen: true,
          context: context,
          builder: (context) => SignUpScreen(),
        );
      },
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset('assets/images/throw_away.svg', height: MediaQuery.of(context).size.height * 0.3),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
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
                    decoration: InputDecoration(
                      label: Text('Adres email'),
                    ),
                    onChanged: (value) => email.value = value,
                  ),
                  Column(
                    children: [
                      TextFormField(
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
                        ),
                        onChanged: (value) => password.value = value,
                      ),
                      SizedBox(height: 6.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Zapomniałeś hasła?', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authServiceProvider).signIn(email: email.value, password: password.value);
                      Navigator.of(context).pop();
                    },
                    child: Center(child: Text('Zaloguj się')),
                  ),
                  Text('Lub', style: Theme.of(context).textTheme.labelLarge),
                  OutlinedButton(
                    onPressed: () {},
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
      ],
    );
  }
}
