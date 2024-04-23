class ParkingArea {
  final String parkingID;
  final String providerID;
  final String parkingName;
  final int price;
  final String parkingPictureURL;
  final Map address;
  final List review;
  final int distance;

  ParkingArea({
    required this.parkingID,
    required this.providerID,
    required this.parkingName,
    required this.price,
    required this.parkingPictureURL,
    required this.address,
    required this.review,
    required this.distance,
  });

  factory ParkingArea.fromJson(Map<String, dynamic> json) {
    return ParkingArea(
      parkingID: json['_id'],
      providerID: json['provider_id'],
      parkingName: json['parking_name'],
      price: json['price'],
      parkingPictureURL: json['parking_picture_url'],
      address: json['address'],
      review: json['review'],
      distance: json['distance'],
    );
  }
}
