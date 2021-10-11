import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:usg_jub/services/auth_service.dart';

Future<void> registerServices() async {
  await Firebase.initializeApp();
  Get.put(AuthService(FirebaseAuth.instance), permanent: true);
  //await Get.find<AuthService>().auth.useAuthEmulator('localhost', 9099);
  await Get.find<AuthService>().firstCheck.future;
}
