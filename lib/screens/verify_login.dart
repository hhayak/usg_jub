import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
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
    if (email.isNotEmpty && link.isNotEmpty) {
      try {
        var credential = await auth.emailLogin(email, link);
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          auth.initLock(credential.user!.uid);
          var major = await getMajor();
          credential.user!.updateDisplayName(major);
        }
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

  Future<String> getMajor() async {
    final majorControl = FormControl<String>(validators: [Validators.required]);
    const List<String> majors = [
      'CHEM',
      'CS',
      'EES',
      'ECE',
      'GEM',
      'IEM',
      'IMS',
      'IBA',
      'IRPH',
      'MATH',
      'PHY',
      'PSY',
      'SMP',
    ];
    var selectedMajor = await Get.defaultDialog<String>(
      barrierDismissible: false,
      title: 'Select your Major',
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: ReactiveDropdownField<String>(
          formControl: majorControl,
          decoration: const InputDecoration(labelText: 'Major'),
          items: majors
              .map((e) => DropdownMenuItem<String>(
                    child: Text(e),
                    value: e,
                  ))
              .toList(),
        ),
      ),
      textConfirm: 'Confirm',
      onConfirm: () => Get.back<String>(
          result: majorControl.value, canPop: majorControl.valid),
    );

    return selectedMajor!;
  }
}
