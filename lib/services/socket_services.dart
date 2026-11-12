// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// // class SocketIoService {
// //   static final SocketIoService _instance = SocketIoService._internal();
// //   factory SocketIoService() => _instance;
// //   SocketIoService._internal();
// //
// //   IO.Socket? _socket;
// //
// //   final _controller = StreamController<dynamic>.broadcast();
// //   Stream<dynamic> get stream => _controller.stream;
// //
// //   bool get isConnected => _socket?.connected == true;
// //
// //   /// CONNECT
// //   void connect({
// //         Map<String, dynamic>? query,
// //         Map<String, dynamic>? extraHeaders,
// //         String? token,
// //         String? driverId,
// //       }) {
// //     if (_socket != null && _socket!.connected) return;
// //    print("driverId: $driverId");
// //    print("token:: $token");
// //     _socket = IO.io(
// //       'http://66.116.207.180:3000',
// //       IO.OptionBuilder()
// //           .setTransports(['websocket', 'polling'])
// //           .enableAutoConnect()
// //           .enableReconnection()
// //           .setReconnectionDelay(1000)
// //           .setReconnectionAttempts(5)
// //           .build(),
// //     );
// //     _socket?.connect();
// //     _socket?.onConnect((_) {
// //       log('Socket connected');
// //       _socket?.emit('driver:auth', {
// //         'driver_id' : driverId,
// //         'token': token,
// //       });
// //     });
// //     _socket!.on('driver:authenticated', (data) {
// //       print('✅ Driver authenticated:: $data');
// //     });
// //
// //     _socket!.on('ride:accept_confirmed', (data) {
// //       print('✅ Ride accepted: $data');
// //      // currentRideId = data['ride_id'];
// //       //sendLocation( lat: null, lng: null, rideId: data['ride_id'],);
// //     });
// //
// //     _socket?.onDisconnect((_) {
// //       debugPrint('[SOCKET] 🔌 Disconnected');
// //     });
// //
// //     _socket?.onError((data) {
// //       debugPrint('[SOCKET] ❌ Error $data');
// //       _controller.addError(data);
// //     });
// //
// //     _socket?.onReconnect((_) {
// //       debugPrint('[SOCKET] 🔁 Reconnected');
// //     });
// //
// //     _socket?.onAny((event, data) {
// //       try {
// //         final decoded = data is String ? jsonDecode(data) : data;
// //         _controller.add({'event': event, 'data': decoded});
// //       } catch (_) {
// //         _controller.add({'event': event, 'data': data});
// //       }
// //     });
// //
// //
// //
// //
// //   }
// //
// //   void sendLocation({
// //     required double lat,
// //     required double lng,
// //     required int rideId,
// //   }) {
// //     if (_socket != null && _socket!.connected) {
// //       _socket!.emit('driver:location_update', {
// //         'latitude': lat,
// //         'longitude': lng,
// //         'ride_id': rideId,
// //       });
// //       print('📍 Location sent: $lat, $lng');
// //     }
// //
// //    // print("📡 location sent => $payload");
// //   }
// //
// //   /// EMIT / SEND DATA
// //   void send(String event, dynamic data) {
// //     if (!isConnected) {
// //       debugPrint('[SOCKET] ❌ Send failed: not connected');
// //       return;
// //     }
// //
// //     final payload = data is String ? data : jsonEncode(data);
// //     _socket?.emit(event, payload);
// //
// //     debugPrint('[SOCKET] 📤 $event → ${_truncate(payload)}');
// //   }
// //
// //   /// LISTEN TO SPECIFIC EVENT
// //   void on(String event, Function(dynamic) handler) {
// //     _socket?.on(event, (data) {
// //       handler(data);
// //     });
// //   }
// //
// //   /// DISCONNECT
// //   void disconnect() {
// //     _socket?.disconnect();
// //     _socket?.dispose();
// //     _socket = null;
// //   }
// //
// //   /// CLEANUP
// //   void dispose() {
// //     disconnect();
// //     _controller.close();
// //   }
// //
// //   String _truncate(String text, {int max = 2000}) {
// //     if (text.length <= max) return text;
// //     return '${text.substring(0, max)}...(${text.length} chars)';
// //   }
// // }
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:geolocator/geolocator.dart';
//
// /// Complete Socket.IO Service for Driver with Full Flow
// class SocketIoService {
//   static final SocketIoService _instance = SocketIoService._internal();
//   factory SocketIoService() => _instance;
//   SocketIoService._internal();
//
//   IO.Socket? _socket;
//   final _controller = StreamController<dynamic>.broadcast();
//   StreamSubscription<Position>? _locationStream;
//
//   // Current state
//   int? _currentDriverId;
//   String? _currentToken;
//   int? _currentRideId;
//   bool _isLocationTracking = false;
//
//   Stream<dynamic> get stream => _controller.stream;
//   bool get isConnected => _socket?.connected == true;
//   int? get currentRideId => _currentRideId;
//   bool get isLocationTracking => _isLocationTracking;
//
//   /// ============================================
//   /// CONNECT TO SOCKET.IO
//   /// ============================================
//   void connect({
//     required String driverId,
//     required String token,
//   })
//   {
//     if (_socket != null && _socket!.connected) {
//       debugPrint('[SOCKET] Already connected');
//       return;
//     }
//
//     _currentDriverId = int.tryParse(driverId);
//     _currentToken = token;
//
//     debugPrint('[SOCKET] Connecting...');
//     debugPrint('Driver ID: $driverId');
//     debugPrint('Token: ${token.substring(0, 20)}...');
//
//     _socket = IO.io(
//       'http://66.116.207.180:3000',
//       IO.OptionBuilder()
//           .setTransports(['websocket', 'polling'])
//           .enableAutoConnect()
//           .enableReconnection()
//           .setReconnectionDelay(1000)
//           .setReconnectionAttempts(5)
//           .setTimeout(20000)
//           .build(),
//     );
//
//     _setupEventListeners();
//     _socket?.connect();
//   }
//
//   void acceptRide(int rideId, int userId) {
//     _socket!.emit('ride:accept', {
//       'ride_id': rideId,
//       'user_id': userId,
//     });
//   }
//
//   void setAvailable() {
//     _socket!.emit('driver:status_update', {
//       'status': 'available',
//     });
//   }
//
//   /// ============================================
//   /// SETUP ALL EVENT LISTENERS
//   /// ============================================
//   void _setupEventListeners() {
//     // Connection events
//     _socket?.onConnect((_) {
//       debugPrint('[SOCKET] ✅ Connected');
//       _authenticate();
//     });
//
//     _socket?.onDisconnect((_) {
//       debugPrint('[SOCKET] 🔌 Disconnected');
//       _stopLocationTracking();
//     });
//
//     _socket?.onError((data) {
//       debugPrint('[SOCKET] ❌ Error: $data');
//       _controller.addError(data);
//     });
//
//     _socket?.onReconnect((_) {
//       debugPrint('[SOCKET] 🔁 Reconnected');
//       _authenticate();
//     });
//
//     // ============================================
//     // AUTHENTICATION EVENTS
//     // ============================================
//     _socket?.on('driver:authenticated', (data) {
//       debugPrint('[SOCKET] ✅ Driver authenticated: $data');
//       _controller.add({
//         'event': 'driver:authenticated',
//         'data': data,
//       });
//     });
//
//     _socket?.on('driver:auth_failed', (data) {
//       debugPrint('[SOCKET] ❌ Authentication failed: $data');
//       _controller.add({
//         'event': 'driver:auth_failed',
//         'data': data,
//       });
//     });
//
//     // ============================================
//     // RIDE ASSIGNMENT EVENTS
//     // ============================================
//     _socket?.on('new_ride_assigned', (data) {
//       debugPrint('[SOCKET] 📨 New ride assigned: $data');
//       _controller.add({
//         'event': 'new_ride_assigned',
//         'data': data,
//       });
//     });
//
//     // ============================================
//     // RIDE ACCEPTANCE EVENTS
//     // ============================================
//     _socket?.on('ride:accept_confirmed', (data) {
//       debugPrint('[SOCKET] ✅ Ride accepted confirmed: $data');
//       _currentRideId = data['ride_id'];
//
//       _controller.add({
//         'event': 'ride:accept_confirmed',
//         'data': data,
//       });
//
//       // ⭐ AUTO START LOCATION TRACKING
//       if (_currentRideId != null) {
//         startLocationTracking(_currentRideId!);
//       }
//     });
//
//     // ============================================
//     // LOCATION UPDATE EVENTS
//     // ============================================
//     _socket?.on('driver:location_update_confirmed', (data) {
//       debugPrint('[SOCKET] 📍 Location update confirmed: $data');
//       _controller.add({
//         'event': 'driver:location_update_confirmed',
//         'data': data,
//       });
//     });
//
//     _socket?.on('driver:location_update_failed', (data) {
//       debugPrint('[SOCKET] ❌ Location update failed: $data');
//       _controller.add({
//         'event': 'driver:location_update_failed',
//         'data': data,
//       });
//     });
//
//     // ============================================
//     // RIDE STATUS EVENTS
//     // ============================================
//     _socket?.on('ride:status_changed', (data) {
//       debugPrint('[SOCKET] 🔄 Ride status changed: $data');
//       _controller.add({
//         'event': 'ride:status_changed',
//         'data': data,
//       });
//
//       // Stop location tracking if ride completed
//       if (data['status'] == 'completed' || data['status'] == 'cancelled') {
//         _stopLocationTracking();
//         _currentRideId = null;
//       }
//     });
//
//     // ============================================
//     // CATCH ALL EVENTS (for debugging)
//     // ============================================
//     _socket?.onAny((event, data) {
//       try {
//         final decoded = data is String ? jsonDecode(data) : data;
//         debugPrint('[SOCKET] 📡 Event: $event');
//         _controller.add({
//           'event': event,
//           'data': decoded,
//         });
//       } catch (e) {
//         _controller.add({
//           'event': event,
//           'data': data,
//         });
//       }
//     });
//   }
//
//   /// ============================================
//   /// AUTHENTICATE DRIVER
//   /// ============================================
//   void _authenticate() {
//     if (_socket == null || !_socket!.connected) {
//       debugPrint('[SOCKET] ❌ Cannot authenticate: not connected');
//       return;
//     }
//
//     if (_currentDriverId == null || _currentToken == null) {
//       debugPrint('[SOCKET] ❌ Cannot authenticate: missing credentials');
//       return;
//     }
//
//     debugPrint('[SOCKET] 🔐 Authenticating driver...');
//     _socket?.emit('driver:auth', {
//       'driver_id': _currentDriverId,
//       'token': _currentToken,
//     });
//   }
//
//   /// ============================================
//   /// START LOCATION TRACKING
//   /// ============================================
//   Future<void> startLocationTracking(int rideId) async {
//     if (_isLocationTracking) {
//       debugPrint('[SOCKET] ⚠️ Location tracking already active');
//       return;
//     }
//
//     if (!isConnected) {
//       debugPrint('[SOCKET] ❌ Cannot start tracking: not connected');
//       return;
//     }
//
//     // Request location permissions
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       debugPrint('[SOCKET] ❌ Location services disabled');
//       _controller.addError('Location services disabled');
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         debugPrint('[SOCKET] ❌ Location permission denied');
//         _controller.addError('Location permission denied');
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       debugPrint('[SOCKET] ❌ Location permission denied forever');
//       _controller.addError('Location permission denied forever');
//       return;
//     }
//
//     _currentRideId = rideId;
//     _isLocationTracking = true;
//
//     debugPrint('[SOCKET] 📍 Starting location tracking for ride $rideId');
//
//     // Start location stream
//     _locationStream = Geolocator.getPositionStream(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10, // Update every 10 meters
//         timeLimit: Duration(seconds: 5),
//       ),
//     ).listen(
//           (Position position) {
//         // Send location update
//         sendLocation(
//           lat: position.latitude,
//           lng: position.longitude,
//           rideId: rideId,
//         );
//       },
//       onError: (error) {
//         debugPrint('[SOCKET] ❌ Location error: $error');
//         _controller.addError(error);
//       },
//     );
//
//     _controller.add({
//       'event': 'location_tracking_started',
//       'data': {'ride_id': rideId},
//     });
//   }
//
//   /// ============================================
//   /// STOP LOCATION TRACKING
//   /// ============================================
//   void _stopLocationTracking() {
//     if (!_isLocationTracking) return;
//
//     _locationStream?.cancel();
//     _locationStream = null;
//     _isLocationTracking = false;
//
//     debugPrint('[SOCKET] 🛑 Location tracking stopped');
//
//     _controller.add({
//       'event': 'location_tracking_stopped',
//       'data': {},
//     });
//   }
//
//   /// ============================================
//   /// SEND LOCATION UPDATE
//   /// ============================================
//   void sendLocation({
//     required double lat,
//     required double lng,
//     required int rideId,
//    // required int userId,
//   }) {
//     if (_socket == null || !_socket!.connected) {
//       debugPrint('[SOCKET] ❌ Cannot send location: not connected');
//       return;
//     }
//     _socket?.emit('ride:accept', {
//       'user_id': 1,
//       'ride_id': rideId,
//     });
//     _socket?.emit('driver:location_update', {
//       'latitude': lat,
//       'longitude': lng,
//       'ride_id': rideId,
//     });
//
//     debugPrint('[SOCKET] 📍 Location sent: $lat, $lng (Ride: $rideId)');
//   }
//
//   /// ============================================
//   /// MANUALLY SEND CURRENT LOCATION (One-time)
//   /// ============================================
//   Future<void> sendCurrentLocation(int rideId) async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       sendLocation(
//         lat: position.latitude,
//         lng: position.longitude,
//         rideId: rideId,
//       );
//     } catch (e) {
//       debugPrint('[SOCKET] ❌ Error getting current location: $e');
//       _controller.addError(e);
//     }
//   }
//
//   /// ============================================
//   /// UPDATE DRIVER STATUS
//   /// ============================================
//   void updateDriverStatus(String status) {
//     if (!isConnected) {
//       debugPrint('[SOCKET] ❌ Cannot update status: not connected');
//       return;
//     }
//
//     _socket?.emit('driver:status_update', {
//       'status': status, // 'available' or 'unavailable'
//     });
//
//     debugPrint('[SOCKET] 🔄 Driver status updated: $status');
//   }
//
//   /// ============================================
//   /// LISTEN TO SPECIFIC EVENT
//   /// ============================================
//   void on(String event, Function(dynamic) handler) {
//     _socket?.on(event, (data) {
//       handler(data);
//     });
//   }
//
//   /// ============================================
//   /// EMIT CUSTOM EVENT
//   /// ============================================
//   void emit(String event, dynamic data) {
//     if (!isConnected) {
//       debugPrint('[SOCKET] ❌ Cannot emit: not connected');
//       return;
//     }
//
//     _socket?.emit(event, data);
//     debugPrint('[SOCKET] 📤 Emitted: $event');
//   }
//
//   /// ============================================
//   /// DISCONNECT
//   /// ============================================
//   void disconnect() {
//     _stopLocationTracking();
//     _socket?.disconnect();
//     _socket?.dispose();
//     _socket = null;
//     _currentRideId = null;
//     _currentDriverId = null;
//     _currentToken = null;
//     debugPrint('[SOCKET] 👋 Disconnected');
//   }
//
//   /// ============================================
//   /// CLEANUP
//   /// ============================================
//   void dispose() {
//     disconnect();
//     _controller.close();
//   }
// }
//
// /// ============================================
// /// USAGE EXAMPLE
// /// ============================================
//
// /*
// // 1. Initialize service
// final socketService = SocketIoService();
//
// // 2. Connect after driver login
// void onDriverLogin(String driverId, String token) {
//   socketService.connect(
//     driverId: driverId,
//     token: token,
//   );
// }
//
// // 3. Listen to all events
// socketService.stream.listen((event) {
//   switch (event['event']) {
//     case 'driver:authenticated':
//       print('Driver authenticated');
//       break;
//
//     case 'new_ride_assigned':
//       final rideData = event['data'];
//       showRideRequestDialog(rideData);
//       break;
//
//     case 'ride:accept_confirmed':
//       final data = event['data'];
//       print('Ride ${data['ride_id']} accepted');
//       // Location tracking starts automatically!
//       break;
//
//     case 'driver:location_update_confirmed':
//       print('Location update confirmed');
//       break;
//
//     case 'ride:status_changed':
//       final data = event['data'];
//       print('Ride status: ${data['status']}');
//       break;
//   }
// });
//
// // 4. Accept ride (via API)
// Future<void> acceptRide(int rideId) async {
//   final response = await http.post(
//     Uri.parse('https://deliverymate.volive.me/alodrive/api/driver/rides/$rideId/accept'),
//     headers: {'Authorization': 'Bearer $token'},
//   );
//
//   // Socket.IO will automatically receive 'ride:accept_confirmed'
//   // Location tracking will start automatically
// }
//
// // 5. Manual location send (if needed)
// socketService.sendCurrentLocation(rideId);
//
// // 6. Stop tracking when ride completes
// void onRideCompleted() {
//   socketService.disconnect();
// }
//


/// ============================================
/// FLUTTER DRIVER SOCKET.IO SERVICE
/// ============================================
///
/// This file contains the complete Socket.IO service for driver app
/// Works perfectly with websocket-server.js
///
/// WebSocket Server: http://66.116.207.180:3000
/// ============================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';

class SocketIoService {
  static final SocketIoService _instance = SocketIoService._internal();
  factory SocketIoService() => _instance;
  SocketIoService._internal();

  IO.Socket? _socket;
  final _controller = StreamController<dynamic>.broadcast();
  StreamSubscription<Position>? _locationStream;

  // Current state
  int? _currentDriverId;
  int? _currentUserId;
  String? _currentToken;
  int? _currentRideId;
  bool _isLocationTracking = false;

  Stream<dynamic> get stream => _controller.stream;
  bool get isConnected => _socket?.connected == true;
  int? get currentRideId => _currentRideId;
  bool get isLocationTracking => _isLocationTracking;

  /// ============================================
  /// CONNECT TO SOCKET.IO
  /// ============================================
  void connect({
    required String driverId,
    required String token,
  }) {
    if (_socket != null && _socket!.connected) {
      debugPrint('[SOCKET] Already connected');
      return;
    }

    _currentDriverId = int.tryParse(driverId);
    _currentToken = token;

    debugPrint('[SOCKET] Connecting...');
    debugPrint('Driver ID: $driverId');
    debugPrint('Token: ${token.substring(0, 20)}...');

    _socket = IO.io(
      'ws://66.116.207.180:3000',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .setTimeout(20000)
          .build(),
    );

    _setupEventListeners();
    _socket?.connect();
  }

  /// ============================================
  /// SETUP ALL EVENT LISTENERS
  /// ============================================
  void _setupEventListeners() {
    // Connection events
    _socket?.onConnect((_) {
      debugPrint('[SOCKET] ✅ Connected ${_socket?.id}');
      _authenticate();
    });

    _socket?.onDisconnect((_) {
      debugPrint('[SOCKET] 🔌 Disconnected');
      _stopLocationTracking();
    });

    _socket?.onError((data) {
      debugPrint('[SOCKET] ❌ Error: $data');
      _controller.addError(data);
    });

    _socket?.onReconnect((_) {
      debugPrint('[SOCKET] 🔁 Reconnected');
      _authenticate();
    });

    // ============================================
    // AUTHENTICATION EVENTS
    // ============================================
    _socket?.on('driver:authenticated', (data) {
      debugPrint('[SOCKET] ✅ Driver authenticated: $data');
      _controller.add({
        'event': 'driver:authenticated',
        'data': data,
      });
    });



    _socket?.on('driver:auth_failed', (data) {
      debugPrint('[SOCKET] ❌ Authentication failed: $data');
      _controller.add({
        'event': 'driver:auth_failed',
        'data': data,
      });
    });

    // ============================================
    // RIDE ASSIGNMENT EVENTS
    // ============================================
    _socket?.on('new_ride_assigned', (data) {
      debugPrint('[SOCKET] 📨 New ride assigned: $data');
      _controller.add({
        'event': 'new_ride_assigned',
        'data': data,
      });
    });

    _socket?.on('user:auth', (data) {
      debugPrint('[SOCKET] ✅ User authenticated: $data');
      _controller.add({
        'event': 'user:auth',
        'data': data,
      });
    });

    // ============================================
    // RIDE ACCEPTANCE EVENTS
    // ============================================
    _socket?.on('ride:accept_confirmed', (data) {
      debugPrint('[SOCKET] ✅ Ride accepted confirmed: $data');
      _currentRideId = data['ride_id'];

      _controller.add({
        'event': 'ride:accept_confirmed',
        'data': data,
      });

      // ⭐ AUTO START LOCATION TRACKING
      if (_currentRideId != null) {
        startLocationTracking(_currentRideId!);
      }
    });

    _socket?.on('ride:accept_failed', (data) {
      debugPrint('[SOCKET] ❌ Ride accept failed: $data');
      _controller.add({
        'event': 'ride:accept_failed',
        'data': data,
      });
    });

    // ============================================
    // LOCATION UPDATE EVENTS
    // ============================================
    _socket?.on('driver:location_update', (data) {
      debugPrint('[SOCKET] 📍 Location update confirmed: $data');
      _controller.add({
        'event': 'driver:location_update',
        'data': data,
      });
    });

    _socket?.on('driver:location_update_failed', (data) {
      debugPrint('[SOCKET] ❌ Location update failed: $data');
      _controller.add({
        'event': 'driver:location_update_failed',
        'data': data,
      });
    });

    // ============================================
    // RIDE STATUS EVENTS
    // ============================================
    _socket?.on('driver:status_update', (data) {
      debugPrint('[SOCKET] 🔄 Ride status changed: $data');
      _controller.add({
        'event': 'driver:status_update',
        'data': data,
      });
     // print("driver stat")
      // Stop location tracking if ride completed
      if (data['status'] == 'completed' || data['status'] == 'cancelled') {
        _stopLocationTracking();
        _currentRideId = null;
      }
    });

    // ============================================
    // CATCH ALL EVENTS (for debugging)
    // ============================================
    _socket?.onAny((event, data) {
      try {
        final decoded = data is String ? jsonDecode(data) : data;
        debugPrint('[SOCKET] 📡 Event: $event $data');
        _controller.add({
          'event': event,
          'data': decoded,
        });
      } catch (e) {
        _controller.add({
          'event': event,
          'data': data,
        });
      }
    });
  }


void userAuth({int? userId}) {
    print("userId:: $userId");
  debugPrint('[SOCKET] 🔐 Authenticating user...');
  _socket?.emit('user:auth', {
    'user_id': userId
  });
}

void statusChange({
    String? status,
  int? userId,
  int? driverId
  //int? rideId,
}) {
  _socket?.emit('driver:status_update', {
    'status': status,
    'user_id' :userId,
    'driver_id': driverId,
    //'ride_id' : rideId,
  });
}
  /// ============================================
  /// AUTHENTICATE DRIVER
  /// ============================================
  void _authenticate() {
    if (_socket == null || !_socket!.connected) {
      debugPrint('[SOCKET] ❌ Cannot authenticate: not connected');
      return;
    }

    if (_currentDriverId == null || _currentToken == null) {
      debugPrint('[SOCKET] ❌ Cannot authenticate: missing credentials');
      return;
    }

    debugPrint('[SOCKET] 🔐 Authenticating driver...');
    _socket?.emit('driver:auth', {
      'driver_id': _currentDriverId,
      'token': _currentToken,
    });


  }

  /// ============================================
  /// ACCEPT RIDE (Call this after API call succeeds)
  /// ============================================
  void acceptRide({
    required int rideId,
    required int userId,
  }) {
    if (!isConnected) {
      debugPrint('[SOCKET] ❌ Cannot accept ride: not connected');
      return;
    }

    debugPrint('[SOCKET] 📤 Emitting ride:accept - Ride: $rideId, User: $userId');

    _socket?.emit('ride:accept', {
      'ride_id': rideId,
      'user_id': userId,
    });
  }

  /// ============================================
  /// START LOCATION TRACKING
  /// ============================================
  Future<void> startLocationTracking(int rideId) async {
    if (_isLocationTracking) {
      debugPrint('[SOCKET] ⚠️ Location tracking already active');
      return;
    }

    if (!isConnected) {
      debugPrint('[SOCKET] ❌ Cannot start tracking: not connected');
      return;
    }

    // Request location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[SOCKET] ❌ Location services disabled');
      _controller.addError('Location services disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[SOCKET] ❌ Location permission denied');
        _controller.addError('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[SOCKET] ❌ Location permission denied forever');
      _controller.addError('Location permission denied forever');
      return;
    }

    _currentRideId = rideId;
    _isLocationTracking = true;

    debugPrint('[SOCKET] 📍 Starting location tracking for ride $rideId');

    // Start location stream
    _locationStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 5),
      ),
    ).listen(
          (Position position) {
        // Send location update
        sendLocation(
          lat: position.latitude,
          lng: position.longitude,
          rideId: rideId,
        );
      },
      onError: (error) {
        debugPrint('[SOCKET] ❌ Location error: $error');
        _controller.addError(error);
      },
    );

    _controller.add({
      'event': 'location_tracking_started',
      'data': {'ride_id': rideId},
    });
  }

  /// ============================================
  /// RELEASE THE CURRENT RIDE
  /// ============================================
  /// Same teardown the `driver:status_update` handler runs when a ride ends,
  /// exposed for the cases where the ride ends over REST instead (driver
  /// cancellation) and no socket event reaches this device. Without it the app
  /// keeps streaming location tagged with a ride it no longer holds.
  void releaseCurrentRide({int? rideId}) {
    if (rideId != null && _currentRideId != null && _currentRideId != rideId) {
      return;
    }

    _stopLocationTracking();
    _currentRideId = null;
  }

  /// ============================================
  /// STOP LOCATION TRACKING
  /// ============================================
  void _stopLocationTracking() {
    if (!_isLocationTracking) return;

    _locationStream?.cancel();
    _locationStream = null;
    _isLocationTracking = false;

    debugPrint('[SOCKET] 🛑 Location tracking stopped');

    _controller.add({
      'event': 'location_tracking_stopped',
      'data': {},
    });
  }

  /// ============================================
  /// SEND LOCATION UPDATE
  /// ============================================
  void sendLocation({
    required double lat,
    required double lng,
    required int rideId,
  }) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('[SOCKET] ❌ Cannot send location: not connected');
      return;
    }
   print("rideId:: $rideId");
    // ⭐ ONLY send location update, NOT ride:accept
    _socket?.emit('driver:location_update', {
      'latitude': lat,
      'longitude': lng,
      'ride_id': rideId,
    });

    // _socket?.on('user:status_updated', (data){
    //   print("socketUpdated:: $data");
    // });

    debugPrint('[SOCKET] 📍 Location sent: $lat, $lng (Ride: $rideId)');
  }

  /// ============================================
  /// MANUALLY SEND CURRENT LOCATION (One-time)
  /// ============================================

  /// ============================================
  /// UPDATE DRIVER STATUS
  /// ============================================

  /// ============================================
  /// LISTEN TO SPECIFIC EVENT
  /// ============================================
  // void on(String event, Function(dynamic) handler) {
  //   _socket?.on(event, (data) {
  //     print("$event, $data,  my datttt-----event");
  //     handler(data);
  //   });
  // }

  /// ============================================
  /// EMIT CUSTOM EVENT
  /// ============================================

  /// ============================================
  /// DISCONNECT
  /// ============================================
  void disconnect() {
    _stopLocationTracking();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRideId = null;
    _currentDriverId = null;
    _currentToken = null;
    debugPrint('[SOCKET] 👋 Disconnected');
  }

  /// ============================================
  /// CLEANUP
  /// ============================================
  void dispose() {
    disconnect();
    _controller.close();
  }
}

/// ============================================
/// USAGE EXAMPLE
/// ============================================
///
/// // 1. Connect to Socket.IO
/// final socketService = SocketIoService();
/// socketService.connect(
///   driverId: '1',
///   token: 'your_token_here',
/// );
///
/// // 2. Listen to events
/// socketService.stream.listen((event) {
///   if (event['event'] == 'new_ride_assigned') {
///     // Show ride request to driver
///   } else if (event['event'] == 'ride:accept_confirmed') {
///     // Ride accepted, location tracking started automatically
///   }
/// });
///
/// // 3. Accept ride via API first
/// final response = await http.post(
///   Uri.parse('https://deliverymate.volive.me/alodrive/api/driver/rides/131/accept'),
///   headers: {'Authorization': 'Bearer $token'},
/// );
///
/// if (response.statusCode == 200) {
///   final data = jsonDecode(response.body);
///   final ride = data['data']['ride'];
///
///   // 4. Emit socket event to notify WebSocket server
///   socketService.acceptRide(
///     rideId: ride['id'],
///     userId: ride['user_id'],
///   );
/// }
///
/// // Location tracking will start automatically after ride:accept_confirmed
/// // OR you can manually start it:
/// // socketService.startLocationTracking(rideId);
///
/// // 5. To stop location tracking
/// // socketService.disconnect(); // This will stop tracking and disconnect
///



