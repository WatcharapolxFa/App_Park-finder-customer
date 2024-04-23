class PointHistory {
  final String content;
  final String type;
  final int point;
  final String timeStampString;
  final String timeStamp;

  PointHistory({
    required this.content,
    required this.type,
    required this.point,
    required this.timeStampString,
    required this.timeStamp,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      content: json['content'],
      type: json['type'],
      point: json['point'],
      timeStampString: json['time_stamp_string'],
      timeStamp: json['time_stamp'],
    );
  }
}
