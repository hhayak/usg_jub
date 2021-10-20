import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/extensions/soft_loading.dart';
import 'package:usg_jub/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final FormControl<String> usernameControl =
      FormControl<String>(validators: [Validators.required]);
  static const String emailDomain = '@jacobs-university.de';

  LoginPage({Key? key}) : super(key: key);

  Future<void> handleLogin() async {
    try {
      if (usernameControl.valid) {
        var email = usernameControl.value! + emailDomain;
        print(email);
        Get.find<AuthService>().sendEmailLogin(email);
        _btnController.softSuccess();
        Get.snackbar('Link sent!',
            'To sign in, please click the link we have sent to your email.',
            duration: const Duration(seconds: 10));
      } else {
        throw Exception('Email not valid');
      }
    } catch (e) {
      _btnController.softError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/usg_logo.png', width: 200, height: 200,),
              const SizedBox(height: 20),
              ReactiveTextField<String>(
                formControl: usernameControl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    label: Text('Email'), suffixText: emailDomain),
                validationMessages: (control) => {
                  ValidationMessage.required: 'Email is required.',
                },
              ),
              const SizedBox(height: 5),
              RoundedLoadingButton(
                color: Colors.blueGrey,
                width: 150,
                controller: _btnController,
                onPressed: handleLogin,
                child: const Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
