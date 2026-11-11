import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(FlupixApp(settings: settings));
}
