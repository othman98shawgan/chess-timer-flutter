import 'package:flutter/material.dart';

import 'resources/colors.dart';
import 'ui/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Timer',
      theme: ThemeData(
        toggleableActiveColor: darkThemeSwatch,
        primarySwatch: darkThemeSwatch,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
