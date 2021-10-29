import 'package:get/get.dart';
import 'package:usg_jub/auth_middleware.dart';
import 'package:usg_jub/screens/home/home.dart';
import 'package:usg_jub/screens/login.dart';

class Screens {
  static const String home = '/';
  static const String login = '/login';
  static const String verifylogin = '/verifylogin';

  static final List<GetPage> getPages = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder.put(() => HomeController()),
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
  ];
}
