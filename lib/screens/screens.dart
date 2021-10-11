import 'package:get/get.dart';
import 'package:usg_jub/auth_middleware.dart';
import 'package:usg_jub/screens/home.dart';
import 'package:usg_jub/screens/login.dart';
import 'package:usg_jub/screens/verify_login.dart';

class Screens {
  static const String home = '/home';
  static const String login = '/login';
  static const String verifylogin = '/verifylogin';

  static final List<GetPage> getPages = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: verifylogin,
      page: () => const VerifyLoginPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
