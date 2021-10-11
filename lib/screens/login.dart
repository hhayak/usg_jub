import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/extensions/soft_loading.dart';
import 'package:usg_jub/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final FormControl<String> emailControl =
      FormControl<String>(validators: [Validators.required, Validators.email]);

  LoginPage({Key? key}) : super(key: key);

  Future<void> handleLogin() async {
    if (emailControl.valid) {
      Get.find<AuthService>().sendEmailLogin(emailControl.value!);
      _btnController.softSuccess();
    } else {
      _btnController.softError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ReactiveTextField<String>(
                formControl: emailControl,
                decoration: const InputDecoration(label: Text('Email')),
                validationMessages: (control) => {
                  ValidationMessage.required: 'Email is required.',
                  ValidationMessage.email:
                      'Email must be a valid Jacobs University email.',
                },
              ),
              RoundedLoadingButton(
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
