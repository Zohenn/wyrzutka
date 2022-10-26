import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/hooks/tap_gesture_recognizer.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/screens/sign_up_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileFeaturesScreen extends HookWidget {
  const ProfileFeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/questions.svg', height: MediaQuery.of(context).size.height * 0.3),
            Text(
              'Jakie możliwości daje konto?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _FeatureCard(
              color: Theme.of(context).primaryColorLight,
              icon: Icon(Icons.add),
              title: 'Dodawanie produktów',
              desc:
                  'Jeżeli zeskanowany przez Ciebie produkt nie znajduje się w naszej bazie, dodaj go i uzupełnij te informacje, które posiadasz.',
            ),
            _FeatureCard(
              icon: Icon(Icons.unfold_more),
              title: 'Propozycje segregacji',
              desc:
                  'Posiadasz wiedzę z zakresu prawidłowej segregacji odpadów? Dodaj swoją propozycję lub zagłosuj na już dodane, aby pomóc innym.',
            ),
            _FeatureCard(
              color: Theme.of(context).primaryColorLight,
              icon: Icon(Icons.receipt_long),
              title: 'Lista produktów',
              desc:
                  'Zapisz najczęściej wyszukiwane przez Ciebie produkty na swojej liście, aby móc łatwiej je odnaleźć.',
            ),
            _FeatureCard(
              icon: Icon(Icons.bar_chart_rounded),
              title: 'Statystyki',
              desc:
                  'Będziesz mógł sprawdzić np. ile produktów dodałeś, ile Twoich propozycji segregacji zostało zatwierdzonych. Te informacje będą też widoczne dla innych użytkowników.',
            ),
            GutterColumn(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => showDefaultBottomSheet(
                    context: context,
                    fullScreen: true,
                    builder: (context) => SignUpScreen(),
                  ),
                  child: Center(child: Text('Zarejestruj się')),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Masz już konto? '),
                      TextSpan(
                        text: 'Zaloguj się',
                        recognizer: signInGestureRecognizer,
                        style: TextStyle(color: AppColors.primaryDarker),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    Key? key,
    this.color,
    required this.icon,
    required this.title,
    required this.desc,
  }) : super(key: key);

  final Color? color;
  final Widget icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                SizedBox(width: 16.0),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SizedBox(height: 4.0),
            Text(desc),
          ],
        ),
      ),
    );
  }
}
