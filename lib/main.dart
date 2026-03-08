import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // Setup error handling
  App.setupErrorHandling();

  runApp(const App());
}
