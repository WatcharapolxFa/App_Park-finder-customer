

class Message {
  final String senderId;
  final String reciverId;
  final String text;
  DateTime time;


  String? senderName; // เพิ่ม senderName
  String? reciverName; // เพิ่ม receiverName

  Message({
    required this.senderId,
    required this.reciverId,
    required this.text,
    required this.time,
    this.senderName, // เพิ่ม senderName
    this.reciverName, // เพิ่ม receiverName
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['SenderID'],
      reciverId: json['ReciverID'],
      text: json['Message']['text'],
      time: DateTime.parse(json['Message']['time_stamp']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'reciverId': reciverId,
      'text': text,
      'time': time.toIso8601String(),
    };
  }


}
