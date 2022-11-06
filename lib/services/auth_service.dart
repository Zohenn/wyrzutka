import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/repositories/user_provider.dart';

final authServiceProvider = Provider((ref) => AuthService(ref));

class UserNotFoundException extends Error {}

class AuthService {
  const AuthService(this.ref);

  final Ref ref;

  FirebaseAuth get auth => ref.watch(firebaseAuthProvider);

  UserRepository get userRepository => ref.watch(userRepositoryProvider);

  // todo: what if somebody tries to register with email that is already tied to some google account? will it be merged?
  Future<AppUser> signUp({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.updateDisplayName('$name $surname');
    return await _createUserDoc(userCredential: userCredential, email: email, name: name, surname: surname);
  }

  Future<AppUser> _createUserDoc({
    required UserCredential userCredential,
    required String email,
    required String name,
    required String surname,
  }) async {
    final user = await userRepository.createAndGet(
      AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        surname: surname,
        role: Role.user,
        signUpDate: FirestoreDateTime.serverTimestamp(),
      ),
    );
    ref.read(authUserProvider.notifier).state = user;
    return user;
  }

  Future<AppUser> _createUserDocFromGoogleCredential(UserCredential userCredential) {
    // todo: perhaps there's a better way, since displayName can contain anything
    final user = userCredential.user!;
    final nameParts = user.displayName!.split(' ');
    final name = nameParts.first;
    final surname = nameParts.skip(1).join(' ');
    return _createUserDoc(userCredential: userCredential, email: user.email!, name: name, surname: surname);
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    try {
      return await _getUserData(userCredential);
    } on UserNotFoundException catch (e) {
      return await _createUserDocFromGoogleCredential(userCredential);
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    final userCredential = await _googleSignIn();

    // This means that sign in was cancelled by user.
    if (userCredential == null) {
      return null;
    }

    try {
      return await _getUserData(userCredential);
    } on UserNotFoundException catch (e) {
      return await _createUserDocFromGoogleCredential(userCredential);
    }
  }

  Future<AppUser> _getUserData(UserCredential userCredential) async {
    final user = await userRepository.fetchId(userCredential.user!.uid, true);
    if (user == null) {
      throw UserNotFoundException();
    }
    ref.read(authUserProvider.notifier).state = user;
    return user;
  }

  Future<UserCredential?> _googleSignIn() async {
    final GoogleSignInAccount? googleUser = await ref.read(googleSignInProvider).signIn();

    // This means that sign in was cancelled by user.
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await ref.read(firebaseAuthProvider).signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await auth.signOut();
    ref.read(authUserProvider.notifier).state = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}