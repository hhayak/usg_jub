import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/constants/majors.dart';
import 'package:usg_jub/extensions/soft_loading.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final _loginBtnController = RoundedLoadingButtonController();
  final _registerBtnController = RoundedLoadingButtonController();
  final FormGroup form = FormGroup({
    'username': FormControl<String>(validators: [Validators.required]),
    'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)]),
  });
  static const String emailDomain = '@jacobs-university.de';

  LoginPage({Key? key}) : super(key: key);

  Future<void> handleLogin() async {
    try {
      if (form.valid) {
        var email = form.control('username').value! + emailDomain;
        var credential = await Get.find<AuthService>()
            .login(email, form.control('password').value!);
        if (!credential.user!.emailVerified) {
          var major = await getMajor();
          if (major.isEmpty) {
            throw Exception('Major is required.');
          }
          credential.user!.updateDisplayName(major);
          throw Exception('Email is not verified.');
        } else {
          _loginBtnController.success();
          Get.offNamed(Screens.home);
        }
      } else {
        throw Exception('Email not valid');
      }
    } catch (e) {
      Get.find<AuthService>().logout();
      Get.snackbar('Login Failed', e.toString(),
          duration: const Duration(seconds: 10),
          mainButton: e.toString() == 'Exception: Email is not verified.'
              ? TextButton(
                  onPressed: () =>
                      Get.find<AuthService>().user!.sendEmailVerification(),
                  child: const Text('Send link'))
              : null);
      _loginBtnController.softError();
    }
  }

  Future<void> handleRegister() async {
    try {
      if (form.valid) {
        var email = form.control('username').value! + emailDomain;
        var credential = await Get.find<AuthService>()
            .register(email, form.control('password').value!);
        if (credential.user != null &&
            credential.additionalUserInfo!.isNewUser) {
          var major = await getMajor();
          if (major.isEmpty) {
            throw Exception('Major is required.');
          }
          credential.user!.updateDisplayName(major);
          credential.user!.sendEmailVerification();
        }
        _registerBtnController.success();
        Get.snackbar('Registration Succesful!',
            'Please verify your email to be able to login and vote. Make sure to check your junk/spam folder.',
            duration: const Duration(seconds: 10));
      }
    } catch (e) {
      Get.snackbar('Registration Failed.', e.toString());
      Get.find<AuthService>().logout();
      _registerBtnController.softError();
    }
  }

  Future<String> getMajor() async {
    final majorControl = FormControl<String>(validators: [Validators.required]);
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
          result: majorControl.value ?? '', canPop: majorControl.valid),
    );

    return selectedMajor!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: AutofillGroup(
            child: ReactiveForm(
              formGroup: form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/usg_logo.png',
                    scale: 0.5,
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'username',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: form.control('password').focus,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                        labelText: 'Email', hintText: 'Username with dot (f.lastname)', suffixText: emailDomain),
                    showErrors: (control) => false,
                  ),
                  const SizedBox(height: 10),
                  ReactiveTextField<String>(
                    formControlName: 'password',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: form.control('password').unfocus,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Must have at least 6 characters.'),
                    obscureText: true,
                    showErrors: (control) => false,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedLoadingButton(
                        color: Colors.blueGrey,
                        width: 150,
                        controller: _loginBtnController,
                        onPressed: handleLogin,
                        child: const Text('Login'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      RoundedLoadingButton(
                        color: Colors.blueGrey,
                        width: 150,
                        controller: _registerBtnController,
                        onPressed: handleRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
