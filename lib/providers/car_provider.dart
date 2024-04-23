import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/models/car_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarProvider with ChangeNotifier {
  List<Car> _cars = [];

  List<Car> get cars => _cars;

  Future<void> fetchCars() async {
    var accessToken = await _getAccessToken();
    var url = Uri.parse('${dotenv.env['HOST']}/customer/car');
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      _cars = data.map((carData) => Car.fromJson(carData)).toList();
      notifyListeners();
    } else {
      // Handle errors
    }
  }

  Future<String?> _getAccessToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'accessToken');
  }
}
