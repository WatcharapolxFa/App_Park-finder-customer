class Cars {
  Cars({
    required this.carID,
    required this.email,
    required this.name,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.carPictureUrl,
    required this.carDefault,
    required this.timeStamp,
  });
  final String carID;
  final String email;
  final String name;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final String carPictureUrl;
  final bool carDefault;
  final String timeStamp;

  Map<String, dynamic> toJson() {
    return {
      '_id': carID,
      'customer_email': email,
      'name': name,
      'license_plate': licensePlate,
      'brand': brand,
      'model': model,
      'color': color,
      'car_picture_url': carPictureUrl,
      'default': carDefault,
      'time_stamp': timeStamp,
    };
  }

  factory Cars.fromJson(Map<String, dynamic> json) {
    return Cars(
      carID: json['_id'],
      email: json['customer_email'],
      name: json['name'],
      licensePlate: json['license_plate'],
      brand: json['brand'],
      model: json['model'],
      color: json['color'],
      carPictureUrl: json['car_picture_url'],
      carDefault: json['default'],
      timeStamp: json['time_stamp'],
    );
  }
}
