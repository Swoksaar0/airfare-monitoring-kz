import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Keep web semantics available for assistive technologies for the app lifetime.
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const KzFlightsMonitorApp());
}

class KzFlightsMonitorApp extends StatelessWidget {
  const KzFlightsMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KZ Flights Price Monitor',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Column(
        children: [
          Material(
            color: Colors.amber.shade100,
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  ApiService.demoMode
                      ? 'ДЕМО: искусственные цены. Запросы к API и push-уведомления отключены.'
                      : 'API-режим: достоверность данных источника требует проверки.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
          ),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
