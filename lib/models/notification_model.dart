class Notifications {
  final String notificationID;
  final String  broadcasType;
  final List?  callbackMethod;
  final String  description;
  final String?  receiverID;
  final String  title;
  DateTime time;

  Notifications({
    required this.notificationID,
    required this.broadcasType,
    this.callbackMethod,
    required this.description,
    this.receiverID,
    required this.title,
    required this.time,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      notificationID: json['_id'],
      broadcasType: json['broadcast_type'],
      callbackMethod: json['callback_method'] ?? [],
      description: json['description'],
      receiverID: json['receiver_id'],
      title: json['title'],
      time: DateTime.parse(json['time_stamp']).toLocal(),
    );
  }
}
