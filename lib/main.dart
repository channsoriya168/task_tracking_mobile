import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_pages.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/app/themes/dark_theme.dart';
import 'package:task_tracking_mobile/app/themes/light_theme.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController(), permanent: true);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeCtrl.isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.home,
        getPages: AppPages.routes,
      ),
    );
  }
}