class History {
  History({
    required this.historyID,
    required this.address,
    required this.dateEnd,
    required this.dateStart,
    required this.hourEnd,
    required this.hourStart,
    required this.minEnd,
    required this.minStart,
    required this.parkingName,
    required this.price,
    required this.parkingPictureURL,
    required this.status,
  });
  final String historyID;
  final String address;
  final String dateEnd;
  final String dateStart;
  final int hourEnd;
  final int hourStart;
  final int minEnd;
  final int minStart;
  final String parkingName;
  final int price;
  final String parkingPictureURL;
  final String status;

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      historyID: json['_id'],
      address: json['address'],
      dateEnd: json['date_end'],
      dateStart: json['date_start'],
      hourEnd: json['hour_end'],
      hourStart: json['hour_start'],
      minEnd: json['min_end'],
      minStart: json['min_start'],
      parkingName: json['parking_name'],
      price: json['price'],
      parkingPictureURL: json['parking_picture_url'],
      status: json['status'],
    );
  }
}
