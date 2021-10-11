import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'USG Jacobs University',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      //home: const HomePage(),
      getPages: Screens.getPages,
      initialRoute: Screens.home,
    );
  }
}
