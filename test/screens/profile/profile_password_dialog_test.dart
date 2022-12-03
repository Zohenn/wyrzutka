import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/screens/profile/dialog/profile_password_dialog.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:mockito/annotations.dart';


import '../../utils.dart';
import 'profile_password_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
])
void main() {
  late AppUser authUser;
  late MockAuthService mockAuthService;

  buildWidget() => wrapForTesting(
    ProfilePasswordDialog(user: authUser),
    overrides: [
      authServiceProvider.overrideWith((ref) => mockAuthService),
    ],
  );

  setUp(() {
    authUser = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
      savedProducts: [],
    );

    mockAuthService = MockAuthService();
  });


  group('', () {
    testWidgets('', (tester) async {

    });
  });
}
