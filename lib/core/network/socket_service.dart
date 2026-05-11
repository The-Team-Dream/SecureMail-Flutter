import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  // Stream for push notifications
  final _notifController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationsStream => _notifController.stream;

  // Stream for sync START events
  final _syncStartController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get syncStartStream => _syncStartController.stream;

  // Stream for sync COMPLETE events
  final _syncController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get syncEventsStream => _syncController.stream;

  void init(String token) {
    if (_socket?.connected ?? false) return;

    final baseUrl = ApiConstants.baseUrlDev;
    
    _socket = io.io(baseUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected to server');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected from server');
    });

    _socket!.on('notification', (data) {
      debugPrint('[Socket] Notification received: $data');
      if (data is Map<String, dynamic>) {
        _notifController.add(data);
      }
    });

    _socket!.on('mailbox_sync_start', (data) {
      debugPrint('[Socket] Sync start event: $data');
      if (data is Map<String, dynamic>) {
        _syncStartController.add(data);
      }
    });

    _socket!.on('mailbox_sync_complete', (data) {
      debugPrint('[Socket] Sync complete event: $data');
      if (data is Map<String, dynamic>) {
        _syncController.add(data);
      }
    });

    _socket!.onConnectError((err) => debugPrint('[Socket] Connect Error: $err'));
    _socket!.onError((err) => debugPrint('[Socket] Error: $err'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}

final socketService = SocketService();
