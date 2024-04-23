import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:parkfinder_customer/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // สำหรับจัดการการเก็บ token

class ChatService {
  late io.Socket socket;
  Function(Message) onMessageReceived;
  Function(List<Message>) onHistoryReceived;
  Function(dynamic) onError;
  final String reserveID;
  final String senderID;
  final String receiverID;
  final storage =
      const FlutterSecureStorage(); // สร้าง instance ของ FlutterSecureStorage

  ChatService({
    required this.onMessageReceived,
    required this.onHistoryReceived,
    required this.onError,
    required this.reserveID,
    required this.senderID,
    required this.receiverID,
  }) {
    socket = io.io(
      'http://34.125.122.199:4700/?user_id=$senderID',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.on('message',
        (data) => {onMessageReceived(Message.fromJson(data['MessageLog'][0]))});
  }

  void sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      var messageData = {
        'reservation_id': reserveID,
        'message': {'Type': 'Text', 'Text': text},
        'receiver_id': receiverID,
        'sender_id': senderID,
      };
      socket.emit('message', messageData);
    }
  }

  Future<void> retrieveMessageLog() async {
    final url = Uri.parse(
        '${dotenv.env['HOST']}/customer/retrieve_message_log?reservation_id=$reserveID&start=0&limit=100');

    // ดึง token จาก storage
    String? token = await storage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ใส่ token ใน header
      },
    );

    // print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final messageLogs = data['data']['MessageLog'] as List;
      final List<Message> retrievedMessages = messageLogs.map((msg) {
        final timestamp = msg['Message']['time_stamp'];
        final DateTime time = DateTime.parse(timestamp.toString()).toLocal();
        return Message(
          senderId: msg['SenderID'],
          reciverId: msg['ReciverID'],
          text: msg['Message']['text'],
          time: time,
        );
      }).toList();

      onHistoryReceived(retrievedMessages.reversed.toList());
    }
  }

  void dispose() {
    if (socket.connected) {
      socket.disconnect();
    }
  }
}
