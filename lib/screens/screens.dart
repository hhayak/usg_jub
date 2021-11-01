import 'package:get/get.dart';
import 'package:usg_jub/auth_middleware.dart';
import 'package:usg_jub/screens/error_page.dart';
import 'package:usg_jub/screens/home/home.dart';
import 'package:usg_jub/screens/home/home_controller.dart';
import 'package:usg_jub/screens/login.dart';

class Screens {
  static const String home = '/';
  static const String login = '/login';
  static const String error = '/error';

  static final List<GetPage> getPages = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder.put(() => HomeController()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: error,
      page: () => const ErrorPage(),
    ),
  ];
}
