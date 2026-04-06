import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/translations/en_US.dart';
import 'package:task_tracking_mobile/core/translations/km_KH.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'km_KH': kmKH};
}
