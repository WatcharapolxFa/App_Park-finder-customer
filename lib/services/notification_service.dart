// ignore_for_file: avoid_print
import 'package:parkfinder_customer/models/notification_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  late io.Socket socket;
  final storage = const FlutterSecureStorage();
  Function(Notifications) onNotificationReceived;
  String userID;

  NotificationService({
    required this.onNotificationReceived,
    required this.userID,
  }) {
    socket = io.io(
      'http://34.125.122.199:4700/?user_id=$userID',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.on(
        'notification',
        (data) => {
              print(data),
              print(Notifications.fromJson(data)),
              // onNotificationReceived(Notifications.fromJson(data['data']))
            });

    socket
        .onConnect((_) => print("Connected to Socket IO Server Notification"));
    socket.onDisconnect(
        (_) => print("Disconnected from Socket IO Server Notification"));
    socket.onConnectError((data) => print("Connect error: $data"));
    socket.onConnectTimeout((data) => print("Connection timeout: $data"));
    socket.onError((data) => print("Error: $data"));
  }

  Future retrieveNotificationLog() async {
    List<Notifications> retrievedNotification = [];
    final url = Uri.parse('${dotenv.env['HOST']}/customer/notification_list');

    // ดึง token จาก storage
    String? token = await storage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ใส่ token ใน header
      },
    );

    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        final notificationLogs = data['data'] as List;
        retrievedNotification = notificationLogs.map((noti) {
          return Notifications(
            notificationID: noti['_id'],
            broadcasType: noti['broadcast_type'],
            callbackMethod: noti['callback_method'],
            description: noti['description'],
            receiverID: noti['receiver_id'],
            time: DateTime.parse(noti['time_stamp'])
                .add(const Duration(hours: 7)),
            title: noti['title'],
          );
        }).toList();
        return retrievedNotification;
      } else {
        return retrievedNotification;
      }
    }
  }

  void dispose() {
    if (socket.connected) {
      socket.disconnect();
    }
  }
}
