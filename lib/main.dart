import 'package:flutter/material.dart';
import 'package:poc/modules/maps/ui/pages/home_page.dart';
import 'package:poc/modules/maps/ui/pages/map_home_page.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POC To Aqui',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MapHomePage(),
    );
  }
}
