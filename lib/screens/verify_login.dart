import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';

class VerifyLoginPage extends StatelessWidget {
  const VerifyLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<VerifyController>(
        init: VerifyController(),
        builder: (controller) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class VerifyController extends GetxController {
  @override
  void onReady() {
    loginWithLink();
    super.onReady();
  }

  Future<void> loginWithLink() async {
    var auth = Get.find<AuthService>();
    var link = 'https://usg-jacobs-university.web.app' + Get.currentRoute;
    var email = Get.parameters['email'] ?? '';
    print('Link: $link Email: $email');
    if (email.isNotEmpty && link.isNotEmpty) {
      try {
        await auth.emailLogin(email, link);
        Get.offAllNamed(Screens.home);
      } on Exception catch (e) {
        Get.offAllNamed(Screens.login);
        Get.snackbar('Login Failed', e.toString(),
            duration: const Duration(seconds: 10));
      }
    } else {
      Get.offAllNamed(Screens.login);
    }
  }
}
