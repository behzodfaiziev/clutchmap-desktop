import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import '../logging/app_logger.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  String? _token;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _isReconnecting = false;
  final AppLogger _logger = AppLogger();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  void connect(String token) {
    _token = token;
    _connectInternal();
  }

  void _connectInternal() {
    try {
      disconnect(); // Close existing connection if any
      final path = '${ApiConfig.wsStrategyPath}?token=$_token';
      final url = ApiConfig.webSocketUrl(path);
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _reconnectAttempt = 0;
      _isReconnecting = false;
      _connectionController.add(true);
      _logger.info("WebSocket connected");
    } catch (e) {
      _logger.error("WebSocket connection failed", e);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isReconnecting || _token == null) return;
    
    _isReconnecting = true;
    _reconnectAttempt++;
    
    final backoff = Duration(
      milliseconds: (500 * _reconnectAttempt.clamp(1, 10)),
    );
    
    _logger.info("WebSocket reconnecting in ${backoff.inMilliseconds}ms (attempt $_reconnectAttempt)");
    _connectionController.add(false);
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(backoff, () {
      _connectInternal();
    });
  }

  Stream? get stream => _channel?.stream;

  void send(dynamic message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(message);
      } catch (e) {
        _logger.error("WebSocket send failed", e);
        _scheduleReconnect();
      }
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isReconnecting = false;
    try {
      _channel?.sink.close();
    } catch (e) {
      // Ignore errors during disconnect
    }
    _channel = null;
    _connectionController.add(false);
  }

  bool get isConnected => _channel != null;

  void dispose() {
    disconnect();
    _connectionController.close();
  }
}

