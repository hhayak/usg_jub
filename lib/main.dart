import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:get/get.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerServices();
  final url = html.window.location.pathname;
  runApp(MyApp(initialUrl: url!));
}

class MyApp extends StatelessWidget {
  final String initialUrl;
  const MyApp({Key? key, required this.initialUrl}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'USG Jacobs University',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      getPages: Screens.getPages,
      initialRoute: initialUrl,
      debugShowCheckedModeBanner: false,
    );
  }
}
