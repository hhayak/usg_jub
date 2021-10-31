import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    var auth = Get.find<AuthService>();
    return auth.user != null
        ? null
        : const RouteSettings(name: Screens.login);
  }
}
