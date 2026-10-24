import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  runApp(const KzFlightsMonitorApp());
}

class KzFlightsMonitorApp extends StatefulWidget {
  const KzFlightsMonitorApp({super.key, this.apiService, this.initialState});
  final ApiService? apiService;
  final MonitorState? initialState;
  @override
  State<KzFlightsMonitorApp> createState() => _KzFlightsMonitorAppState();
}

class _KzFlightsMonitorAppState extends State<KzFlightsMonitorApp> {
  late final ApiService api = widget.apiService ?? ApiService();
  late final Future<MonitorState> ready = widget.initialState != null
      ? Future.value(widget.initialState)
      : SharedPreferences.getInstance()
          .then((prefs) => MonitorState(prefs, demo: api.demo, now: api.now));
  MonitorState? ownedState;

  @override
  void dispose() {
    if (widget.apiService == null) api.dispose();
    ownedState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Airfare KZ',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2458A6)),
          scaffoldBackgroundColor: const Color(0xFFF4F6FA),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: FutureBuilder<MonitorState>(
          future: ready,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Scaffold(
                  body: Center(
                      child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Не удалось открыть локальные настройки. '
                    'Проверьте доступ к хранилищу браузера и перезагрузите страницу.'),
              )));
            }
            if (!snapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (widget.initialState == null) ownedState = snapshot.data;
            return HomeScreen(api: api, state: snapshot.data!);
          },
        ),
      );
}

