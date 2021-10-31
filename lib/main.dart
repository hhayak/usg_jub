import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerServices();
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://f627da5b6dd84d10b1038f124649161a@o1055361.ingest.sentry.io/6041397';
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
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF1a375e)),
        brightness: Brightness.light,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      getPages: Screens.getPages,
      initialRoute: Screens.home,
      debugShowCheckedModeBanner: false,
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
