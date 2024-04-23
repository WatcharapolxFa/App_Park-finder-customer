class Reserve {
  Reserve({
    required this.reserveID,
    required this.providerID,
    required this.providerName,
    required this.orderID,
    required this.parkingName,
    required this.dateStart,
    required this.dateEnd,
    required this.hourStart,
    required this.minStart,
    required this.hourEnd,
    required this.minEnd,
    required this.latitude,
    required this.longitude,
  });
  final String reserveID;
  final String providerID;
  final String providerName;
  final String orderID;
  final String parkingName;
  final String dateStart;
  final String dateEnd;
  final int hourStart;
  final int minStart;
  final int hourEnd;
  final int minEnd;
  final double latitude;
  final double longitude;

  factory Reserve.fromJson(Map<String, dynamic> json) {
    return Reserve(
      reserveID: json['reserve_id'],
      providerID: json['provider_id'],
      providerName: json['ProviderName'],
      orderID: json['order_id'],
      parkingName: json['parking_name'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
      hourStart: json['hour_start'],
      minStart: json['min_start'],
      hourEnd: json['hour_end'],
      minEnd: json['min_end'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
