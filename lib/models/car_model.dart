class Car {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String imageUrl;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.imageUrl,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }
}
