import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/models/parking_area_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParkingAreaService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<List<ParkingArea>> getParkingAreaFavorite() async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    List<ParkingArea> parkingAreaList = [];
    try {
      final url = Uri.parse('${dotenv.env['HOST']}/customer/favorite_area');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body)['data'];
        parkingAreaList =
            jsonList.map((json) => ParkingArea.fromJson(json)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting parking: $e");
    }
    return parkingAreaList;
  }

  Future<ParkingArea?> getParkingAreaDetail(String parkingID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      ParkingArea parkingArea;
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/parking_detail?parking_id=$parkingID');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['data'];
        parkingArea = ParkingArea.fromJson(json);
        return parkingArea;
      }
    } catch (e) {
      // print("Error getting parking: $e");
    }
    return null;
  }

  double calculateAverageReviewScore(reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }

    double totalScore = 0.0;
    for (var review in reviews) {
      totalScore += review['review_score'];
    }

    return totalScore / reviews.length;
  }

  bool isParkingAreaExist(List<ParkingArea> parkingAreas, String newParkingID) {
    for (var area in parkingAreas) {
      if (area.parkingID == newParkingID) {
        return true;
      }
    }
    return false;
  }

  Future<bool> pushPullFavoriteParking(String parkingID, String action) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    final url = Uri.parse(
        '${dotenv.env['HOST']}/customer/favorite_area?parking_id=$parkingID&action=$action');
    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
