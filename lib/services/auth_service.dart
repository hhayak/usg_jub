import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  bool? isAdmin;
  Completer firstCheck = Completer();

  AuthService(this.auth, this.firestore,
      [bool useEmulator = false, bool skipAuth = false]) {
    if (skipAuth) {
      firstCheck.complete();
    } else {
      if (useEmulator) {
        auth.useAuthEmulator('localhost', 9099);
      }
      listentoAuth();
    }
  }

  User? get user => auth.currentUser;

  Future<void> listentoAuth() async {
    await auth.setPersistence(Persistence.LOCAL);
    auth.authStateChanges().listen((user) {
      if (!firstCheck.isCompleted) {
        firstCheck.complete();
      }
    });
  }

  Future<void> logout() async {
    auth.signOut();
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      var credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        //credential.user!.sendEmailVerification();
        initLock(credential.user!.uid);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> sendEmailLogin(String email) async {
    var actionCodeSettings = ActionCodeSettings(
        url: 'https://usg-jacobs-university.web.app/verifylogin?email=$email',
        dynamicLinkDomain: 'usg-jacobs-university.web.app',
        handleCodeInApp: true);
    auth.sendSignInLinkToEmail(
        email: email, actionCodeSettings: actionCodeSettings);
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      var credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      await checkIsAdmin();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential> emailLogin(String email, String link) async {
    if (auth.isSignInWithEmailLink(link)) {
      try {
        var credential =
            await auth.signInWithEmailLink(email: email, emailLink: link);
        await checkIsAdmin();
        return credential;
      } on FirebaseAuthException catch (e) {
        throw Exception(e.message);
      }
    } else {
      throw Exception('Invalid Link');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'auth/invalid-email' || e.code == 'auth/user-not-found') {
        throw Exception(e.message);
      } else {
        throw Exception(
            'Some error occured while sending a password reset link.');
      }
    }
  }

  Future<void> setMajor(String id, String major) async {
    firestore.collection('locks').doc(id).update({'major': major});
  }

  Future<void> initLock(String id) async {
    firestore.collection('locks').doc(id).set({
      'locks': [],
      'major': null,
    });
  }

  Future<bool> checkIsAdmin() async {
    var docRef = await firestore.collection('settings').doc('admins').get();
    List admins = docRef.data()!['admins'];
    isAdmin = admins.contains(user!.email);
    return isAdmin ?? false;
  }
}
