import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/constants/theme.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerServices();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f627da5b6dd84d10b1038f124649161a@o1055361.ingest.sentry.io/6041397';
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'USG Jacobs University',
      theme: lightTheme,
      darkTheme: darkTheme,
      getPages: Screens.getPages,
      initialRoute: Screens.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
