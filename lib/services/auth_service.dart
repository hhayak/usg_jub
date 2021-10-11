import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth;
  bool? isLoggedIn;
  Completer firstCheck = Completer();

  AuthService(this.auth) {
    listentoAuth();
  }

  void listentoAuth() {
    auth.authStateChanges().listen((user) {
      isLoggedIn = !(user == null);
      print('AuthState changed: loggedIn = $isLoggedIn');
      if (!firstCheck.isCompleted) {
        firstCheck.complete();
      }
    });
  }

  Future<void> logout() async {
    auth.signOut();
  }

  Future<void> sendEmailLogin(String email) async {
    var actionCodeSettings = ActionCodeSettings(
        url: 'https://usg-jacobs-university.web.app/verifylogin?email=$email',
        dynamicLinkDomain: 'usg-jacobs-university.web.app',
        handleCodeInApp: true);
    auth.sendSignInLinkToEmail(
        email: email, actionCodeSettings: actionCodeSettings);
  }

  Future<User?> emailLogin(String email, String link) async {
    if (auth.isSignInWithEmailLink(link)) {
      try {
        var credential =
            await auth.signInWithEmailLink(email: email, emailLink: link);
        print('Signed in email: ${credential.user!.email!}');
        isLoggedIn = true;
        return credential.user;
      } on FirebaseAuthException catch (e) {
        throw Exception(e.message);
      }
    } else {
      throw Exception('Invalid Link');
    }
  }
}
