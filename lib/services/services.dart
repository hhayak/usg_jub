import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';

Future<void> registerServices() async {
  await Firebase.initializeApp();
  Get.put(AuthService(FirebaseAuth.instance, FirebaseFirestore.instance), permanent: true);
  Get.put(VoteService(FirebaseFirestore.instance), permanent: true);
  await Get.find<AuthService>().firstCheck.future;
  if (Get.find<AuthService>().isLoggedIn!) {
  await Get.find<AuthService>().checkIsAdmin();
}
}
