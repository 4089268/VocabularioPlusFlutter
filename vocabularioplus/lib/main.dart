import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabularioplus/providers/ajustes_provider.dart';
import 'package:vocabularioplus/providers/palabras_provider.dart';
import 'package:vocabularioplus/screens/home_shell.dart';
import 'package:vocabularioplus/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().inicializar();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (_) => PalabrasProvider()..cargarPalabras()),
        ChangeNotifierProvider( create: (_) => AjustesProvider()..cargar()),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabularioPlus',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F6F3),
        colorScheme: ColorScheme.fromSeed (
          surface: Colors.white12,
          onSurface: Colors.black87,
          primaryContainer: const Color(0xFF0E6B5C),
          onPrimaryContainer: Colors.white,
          secondaryContainer: Colors.white,
          outline: const Color(0xBB0E6B5C),
          seedColor: const Color(0xFF0E6B5C),
          primary: const Color(0xFF0E6B5C),
        ),
        fontFamily: 'IBM Plex Sans',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontWeight: FontWeight.w700
          )
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121412),
        colorScheme: ColorScheme.fromSeed(
          surface: Colors.black87,
          onSurface: Colors.white70,
          primaryContainer: const Color(0xFF0E6B5C),
          onPrimaryContainer: Colors.white,
          secondaryContainer: Colors.black,
          outline: const Color(0xBB0E6B5C),
          seedColor: const Color(0xFF0E6B5C),
          primary: const Color(0xFF0E6B5C),
          brightness: Brightness.dark,
        ),
        fontFamily: 'IBM Plex Sans',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontWeight: FontWeight.w700
          ),
        ),
        useMaterial3: true,
      ),

      home: const _AppInicial(),
    );
  }
}

class _AppInicial extends StatefulWidget {
  const _AppInicial();

  @override
  State<_AppInicial> createState() => _AppInicialState();
}

class _AppInicialState extends State<_AppInicial> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final palabrasProvider = context.read<PalabrasProvider>();
      context.read<AjustesProvider>().reprogramarAlAbrir(palabrasProvider);
    });
  }

  @override
  Widget build(BuildContext context) => const HomeShell();
}