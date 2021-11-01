import 'package:firebase_auth/firebase_auth.dart';
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
    'username': FormControl<String>(
        validators: [Validators.required, _usernameValidator]),
    'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)]),
  });
  static const String emailDomain = '@jacobs-university.de';

  LoginPage({Key? key}) : super(key: key);

  static Map<String, dynamic>? _usernameValidator(
      AbstractControl<dynamic> control) {
    return control.value != null &&
            control.value is String &&
            control.value!.contains('.')
        ? null
        : {'usernameValidator': false};
  }

  Future<void> handleLogin() async {
    Get.focusScope?.unfocus();
    late UserCredential credential;
    try {
      if (form.valid) {
        var email = form.control('username').value! + emailDomain;
        credential = await Get.find<AuthService>()
            .login(email, form.control('password').value!);
        if (!credential.user!.emailVerified) {
          var major = await getMajor();
          if (major.isEmpty) {
            throw Exception('Major is required.');
          }
          Get.find<AuthService>().setMajor(credential.user!.uid, major);
          throw Exception('Email is not verified.');
        } else {
          // Users created before 29.10.2021, used display name to set their major.
          // Bad design. This condition migrates to firestore documents instead.
          if (credential.user!.metadata.creationTime!
                  .isBefore(DateTime(2021, 10, 31)) &&
              credential.user!.displayName != null && !credential.user!.displayName!.contains('@')) {
            Get.find<AuthService>()
                .setMajor(credential.user!.uid, credential.user!.displayName!);
            //credential.user!.updateDisplayName(credential.user!.email);
          }
          _loginBtnController.success();
          Get.offNamed(Screens.home);
        }
      } else {
        throw Exception('Input is not valid');
      }
    } catch (e) {
      if (e.toString() == 'Exception: Email is not verified.') {
        Get.snackbar('Login Failed', e.toString(),
            duration: const Duration(seconds: 10),
            mainButton: TextButton(
                onPressed: () async {
                  await credential.user!.sendEmailVerification();
                  Get.find<AuthService>().logout();
                },
                child: const Text('Send link')));
      } else {
        Get.find<AuthService>().logout();
        Get.snackbar(
          'Login Failed',
          e.toString(),
          duration: const Duration(seconds: 10),
        );
      }
      _loginBtnController.softError();
    }
  }

  Future<void> handleRegister() async {
    //Get.focusScope?.unfocus();
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
          Get.find<AuthService>().setMajor(credential.user!.uid, major);
          credential.user!.sendEmailVerification();
        }
        _registerBtnController.success();
        Get.snackbar('Registration Succesful!',
            'Please verify your email to be able to login and vote. Make sure to check your junk/spam folder.',
            duration: const Duration(seconds: 10));
      } else {
        throw Exception('Input is not valid.');
      }
    } catch (e) {
      Get.snackbar('Registration Failed.', e.toString());
      Get.find<AuthService>().logout();
      _registerBtnController.softError();
    }
  }

  Future<void> handleForgotPassword() async {
    try {
      if (form.control('username').valid) {
        await Get.find<AuthService>().sendPasswordResetEmail(
            form.control('username').value! + emailDomain);
        Get.snackbar('Password reset link sent!',
            'Make sure to check your spam/junk folder.',
            duration: const Duration(seconds: 10));
      } else {
        throw Exception('Email is invalid.');
      }
    } catch (e) {
      Get.snackbar('Failed to reset password.', e.toString());
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
      confirm: ElevatedButton(
        onPressed: () => Get.back<String>(
            result: majorControl.value ?? '', canPop: majorControl.valid),
        child: const Text('Confirm'),
      ),
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
                    scale: 0.3,
                    height: Get.width < 600 ? 100 : 300,
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'username',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: form.control('password').focus,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                        labelText: 'Email (Username with dot ".")',
                        hintText: 'f.lastname',
                        suffixText: emailDomain),
                    showErrors: (control) => false,
                  ),
                  const SizedBox(height: 10),
                  PasswordField(
                    controlName: 'password',
                    form: form,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextButton(
                        onPressed: handleForgotPassword,
                        child: const Text('Reset Password'),
                      ),
                    ),
                  ),
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

class PasswordField extends StatefulWidget {
  final String controlName;
  final FormGroup form;
  const PasswordField({Key? key, required this.controlName, required this.form})
      : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = true;
    super.initState();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: widget.controlName,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: widget.form.control(widget.controlName).unfocus,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Must have at least 6 characters.',
        suffixIcon: IconButton(
            onPressed: _toggleObscureText,
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
      ),
      obscureText: _obscureText,
      showErrors: (control) => false,
    );
  }
}
