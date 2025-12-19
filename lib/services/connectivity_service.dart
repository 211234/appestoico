import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_service.dart';
import 'api_service.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isOnline = true;
  static final List<Function> _onlineCallbacks = [];

  // Inicializar monitoreo de conectividad
  static Future<void> initialize() async {
    // Verificar conectividad inicial
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    // Escuchar cambios de conectividad
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOffline = !_isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);

      // Si pasó de offline a online, sincronizar
      if (wasOffline && _isOnline) {
        _syncPendingData();
        _notifyOnlineCallbacks();
      }
    });
  }

  // Verificar si hay conexión
  static bool get isOnline => _isOnline;

  // Sincronizar datos pendientes
  static Future<void> _syncPendingData() async {
    try {
      final pendingReflections = await OfflineService.getPendingReflections();

      if (pendingReflections.isEmpty) {
        return;
      }

      int synced = 0;
      int failed = 0;

      for (var reflection in pendingReflections) {
        try {
          final type = reflection['type'] as String;
          final date = reflection['date'] as String;
          final text = reflection['text'] as String;
          final id = reflection['id'] as String?;

          if (id != null) {
            // Es una actualización
            if (type == 'morning') {
              await ApiService.updateReflection(id: id, morningText: text);
            } else {
              await ApiService.updateReflection(id: id, eveningText: text);
            }
          } else {
            // Es una nueva reflexión
            if (type == 'morning') {
              await ApiService.saveMorningReflection(
                date: date,
                morningText: text,
              );
            } else {
              await ApiService.saveReflection(date: date, eveningText: text);
            }
          }

          synced++;
        } catch (e) {
          failed++;
        }
      }

      // Limpiar reflexiones sincronizadas
      if (synced > 0) {
        await OfflineService.clearPendingReflections();
        await OfflineService.updateLastSync();
      }
    } catch (e) {}
  }

  // Forzar sincronización manual
  static Future<void> forceSyncNow() async {
    if (_isOnline) {
      await _syncPendingData();
    } else {}
  }

  // Registrar callback para cuando vuelva la conexión
  static void onOnline(Function callback) {
    _onlineCallbacks.add(callback);
  }

  // Notificar a los callbacks
  static void _notifyOnlineCallbacks() {
    for (var callback in _onlineCallbacks) {
      callback();
    }
  }

  // Limpiar callbacks
  static void clearCallbacks() {
    _onlineCallbacks.clear();
  }

  // Cancelar suscripción
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onlineCallbacks.clear();
  }
}
