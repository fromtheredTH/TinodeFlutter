import 'package:flutter/material.dart';
import 'global/app_get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'login.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
 // GetIt.I.registerSingleton<SocialService>(SocialService());
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Login(title: 'Tinode'),
      
    );
  }
}
