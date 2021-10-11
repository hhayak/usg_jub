import 'package:rounded_loading_button/rounded_loading_button.dart';

extension SoftLoading on RoundedLoadingButtonController {
  void softSuccess() {
    success();
    Future.delayed(const Duration(seconds: 2), () => reset());
  }

  void softError() {
    error();
    Future.delayed(const Duration(seconds: 2), () => reset());
  }
}
