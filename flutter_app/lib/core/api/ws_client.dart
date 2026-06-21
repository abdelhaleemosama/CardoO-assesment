import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../env.dart';
import '../../features/readings/data/reading_model.dart';

/// Stream of [Reading] events emitted by the backend WebSocket gateway.
/// Re-creates the socket if the provider is disposed.
final readingStreamProvider = StreamProvider<Reading>((ref) {
  final controller = StreamController<Reading>.broadcast();

  final socket = IO.io(
    Env.apiBaseUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .build(),
  );

  socket.on('reading:new', (data) {
    if (data is Map) {
      controller.add(Reading.fromJson(Map<String, dynamic>.from(data)));
    }
  });

  ref.onDispose(() {
    socket.dispose();
    controller.close();
  });

  return controller.stream;
});

final wsConnectedProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>.broadcast();

  final socket = IO.io(
    Env.apiBaseUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .build(),
  );

  socket.onConnect((_) => controller.add(true));
  socket.onDisconnect((_) => controller.add(false));
  socket.onConnectError((_) => controller.add(false));

  ref.onDispose(() {
    socket.dispose();
    controller.close();
  });

  return controller.stream;
});
