import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/language_controller.dart';
import 'package:task_tracking_mobile/core/services/shorebird_service.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/network/network_info_impl.dart';
import 'package:task_tracking_mobile/routes/app_pages.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/core/themes/dark_theme.dart';
import 'package:task_tracking_mobile/core/themes/light_theme.dart';
import 'package:task_tracking_mobile/core/translations/app_translations.dart';
import 'package:task_tracking_mobile/core/controllers/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Suppress MissingPluginException from connectivity_plus stream activation.
  // The exception is reported through FlutterError, not catchable via try-catch.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is MissingPluginException) return;
    originalOnError?.call(details);
  };

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Read persisted locale before the first frame to avoid a flash.
  final savedIsKhmer = await LanguageController.readSavedIsKhmer();

  Get.put<ShorebirdService>(ShorebirdService(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<LanguageController>(
    LanguageController(initialIsKhmer: savedIsKhmer),
    permanent: true,
  );
  Get.put<NetworkInfoImpl>(NetworkInfoImpl(Connectivity()), permanent: true);
  Get.put<NetworkController>(
    NetworkController(Get.find<NetworkInfoImpl>()),
    permanent: true,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 245, 16, 16),
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
    final langCtrl = Get.find<LanguageController>();
    return Obx(
      () => GetMaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: langCtrl.currentLocale,
        fallbackLocale: const Locale('en', 'US'),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeCtrl.isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
      ),
    );
  }
}
