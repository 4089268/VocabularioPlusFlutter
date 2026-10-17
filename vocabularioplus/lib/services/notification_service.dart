import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/palabra.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _inicializando = false;


  Future<void> inicializar() async {
    if(_inicializando) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS:iosSettings)
    );

    _inicializando = true;
  }

  Future<bool> solicitarPermisos() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    bool concedido = true;

    if(androidImpl != null){
      final otorgado = await androidImpl.requestNotificationsPermission();
      concedido = otorgado ?? true;
    }

    if(iosImpl != null){
      final otorgado = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true
      );
      concedido = otorgado ?? true;
    }

    return concedido;
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }

  /// Programa un lote de notificaciones distribuidas entre [desde] y [hasta],
  /// una por cada vez en [frecuenciaDiaria], durante los próximos [diasAdelante] días.
  Future<void> programarNotificaciones({
    required List<Palabra> palabras,
    required int frecuenciaDiaria,
    required int horaDesde,
    required int horaHasta,
    int diasAdelante = 7,
  }) async {
    await cancelarTodas();

    if (palabras.isEmpty || frecuenciaDiaria <= 0) return;

    final random = Random();
    final rangoHoras = horaHasta - horaDesde;
    if (rangoHoras <= 0) return;

    var idNotificacion = 0;
    final ahora = tz.TZDateTime.now(tz.local);

    for (var dia = 0; dia < diasAdelante; dia++) {
      for (var i = 0; i < frecuenciaDiaria; i++) {
        final palabra = palabras[random.nextInt(palabras.length)];

        // Distribuye las horas de forma pareja dentro del rango, con algo de variación.
        final fraccion = (i + 0.5) / frecuenciaDiaria;
        final horaBase = horaDesde + (rangoHoras * fraccion);
        final hora = horaBase.floor().clamp(horaDesde, horaHasta - 1);
        final minuto = random.nextInt(60);

        var fecha = tz.TZDateTime(
          tz.local,
          ahora.year,
          ahora.month,
          ahora.day + dia,
          hora,
          minuto,
        );

        if (fecha.isBefore(ahora)) continue;

        await _plugin.zonedSchedule(
          idNotificacion++,
          palabra.palabra,
          palabra.significado,
          fecha,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'vocabulario_plus_palabras',
              'Palabras para repasar',
              channelDescription: 'Notificaciones aleatorias con palabras de tu vocabulario',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: palabra.id?.toString(),
        );

      }
    }
  }
}