import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/models/reserve_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReserveService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<bool> scanQRCode(String urlFromQR) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      final url = Uri.parse(urlFromQR);
      final response = await http.post(
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
    } catch (e) {
      // print("Error getting history: $e");
    }
    return false;
  }

  Future<Reserve?> getReserveDetailwithID(String reserveID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    Reserve reserveDetail;
    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/my_reserve_detail?reserve_id=$reserveID');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['data'];
        reserveDetail = Reserve.fromJson(json);
        return reserveDetail;
      }
    } catch (e) {
      // print("Error get reserve detail: $e");
    }
    return null;
  }

  Future createReserve(
      String providerID,
      String parkingID,
      String carID,
      String startDate,
      String endDate,
      TimeOfDay entryTime,
      TimeOfDay exitTime,
      int sumPrice) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      String reserveType = "";
      if (calculateDayDifference(endDate) >= 7) {
        reserveType = "in_advance";
      } else {
        reserveType = "current";
      }
      Map data = {
        'provider_id': providerID,
        'parking_id': parkingID,
        'car_id': carID,
        'date_start': startDate,
        'date_end': endDate,
        'hour_start': entryTime.hour,
        'hour_end': exitTime.hour,
        'min_start': entryTime.minute,
        'min_end': exitTime.minute,
        'payment_chanel': "line_rabbit",
        'type': reserveType,
        'price': sumPrice,
      };
      String body = json.encode(data);
      final url = Uri.parse('${dotenv.env['HOST']}/customer/reserve');

      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: body);
      if (response.statusCode == 200) {
        Map res = jsonDecode(response.body);
        return res;
      } else {
        return null;
      }
    } catch (e) {
      // Failed to load data from Backend
    }
    return null;
  }

  DateTime convertStringtoDateTime(String date) {
    final DateTime dateTime = DateTime(int.parse(date.split("-")[0]),
        int.parse(date.split("-")[1]), int.parse(date.split("-")[2]));
    return dateTime;
  }

  DateTime convertStringtoDateTimewithTimeInt(
      String date, int hourStart, int minStart) {
    final DateTime dateTime = DateTime(int.parse(date.split("-")[0]),
        int.parse(date.split("-")[1]), int.parse(date.split("-")[2]));
    DateTime entryDateTime = DateTime(
        dateTime.year, dateTime.month, dateTime.day, hourStart, minStart);
    return entryDateTime;
  }

  int calculateDayDifference(String datetime) {
    List datetimeSplit = datetime.split("-");
    if (datetimeSplit.length == 3) {
      DateTime targetDate = DateTime(int.parse(datetimeSplit[0]),
          int.parse(datetimeSplit[1]), int.parse(datetimeSplit[2]));
      DateTime now = DateTime.now();
      Duration difference = targetDate.difference(now);
      int daysDifference = difference.inDays;
      return daysDifference;
    }
    return -1;
  }

  int calculateParkingPrice(String startDateInput, TimeOfDay entryTime,
      String endDateInput, TimeOfDay exitTime, int pricePerHour) {
    final DateTime startDate = DateTime(
        int.parse(startDateInput.split("-")[0]),
        int.parse(startDateInput.split("-")[1]),
        int.parse(startDateInput.split("-")[2]));
    final DateTime endDate = DateTime(
        int.parse(endDateInput.split("-")[0]),
        int.parse(endDateInput.split("-")[1]),
        int.parse(endDateInput.split("-")[2]));
    // Convert TimeOfDay to DateTime
    DateTime entryDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, entryTime.hour, entryTime.minute);
    DateTime exitDateTime = DateTime(endDate.year, endDate.month, endDate.day,
        exitTime.hour, exitTime.minute);

    // Calculate duration in hours
    double durationInHours =
        exitDateTime.difference(entryDateTime).inHours.toDouble();

    // Calculate total price
    double totalPrice = durationInHours * pricePerHour;

    return totalPrice.toInt();
  }

  double calculateParkingHour(String startDateInput, TimeOfDay entryTime,
      String endDateInput, TimeOfDay exitTime, int pricePerHour) {
    final DateTime startDate = DateTime(
        int.parse(startDateInput.split("-")[0]),
        int.parse(startDateInput.split("-")[1]),
        int.parse(startDateInput.split("-")[2]));
    final DateTime endDate = DateTime(
        int.parse(endDateInput.split("-")[0]),
        int.parse(endDateInput.split("-")[1]),
        int.parse(endDateInput.split("-")[2]));
    // Convert TimeOfDay to DateTime
    DateTime entryDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, entryTime.hour, entryTime.minute);
    DateTime exitDateTime = DateTime(endDate.year, endDate.month, endDate.day,
        exitTime.hour, exitTime.minute);

    // Calculate duration in hours
    double durationInHours =
        exitDateTime.difference(entryDateTime).inHours.toDouble();

    return durationInHours;
  }

  Future createTransaction(
    String providerID,
    String orderID,
    String parkingID,
    String parkingName,
    double quantity,
    int price,
    int cashback,
  ) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      Map data = {
        "provider_id": providerID,
        "order_id": orderID,
        "parking_id": parkingID,
        "parking_name": parkingName,
        "quantity": quantity,
        "price": price,
        "cashback": cashback
      };
      String body = json.encode(data);
      final url = Uri.parse('${dotenv.env['HOST']}/customer/line-pay/payment');

      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: body);

      if (response.statusCode == 200) {
        Map res = jsonDecode(response.body);
        return res;
      } else {
        return null;
      }
    } catch (e) {
      // Failed to load data from Backend
    }
    return null;
  }

  Future<void> cacheUrl(String reserveID, String url, String timestamp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(reserveID, <String>[url, timestamp]);
  }

  Future<List<String>?> getCachedUrl(String reserveID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(reserveID);
  }

  Future<void> removeUrl(String reserveID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(reserveID);
  }

  Future capturePicture(String orderID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/capture_picture?order_id=$orderID');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['message'];
        return json;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future extendReserve(String orderID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/extend_reserve?order_id=$orderID&action=normal');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      // print(response.body);
      if (response.statusCode == 200) {
        Map res = jsonDecode(response.body);

        return res;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future checkCanReview(String orderID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/check_can_review?order_id=$orderID');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['message'];

        return json;
      } else {
        return json;
      }
    } catch (e) {
      // print("Error check review: $e");
    }
    return false;
  }

  Future<bool> reviewParkingArea(
      String parkingID, int score, String comment, String orderID) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      Map data = {
        "parking_id": parkingID,
        "review_score": score,
        "comment": comment,
        "order_id": orderID
      };
      String body = json.encode(data);
      final url = Uri.parse('${dotenv.env['HOST']}/customer/review');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // print("Error review parking area: $e");
    }
    return false;
  }

  Future checkFine() async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      final url = Uri.parse('${dotenv.env['HOST']}/customer/check_fine');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['data'];

        if (json != null) {
          return json;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      // print("Error check fine: $e");
    }
  }

  Future<bool> confirmCar(String callBackUrl) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      final url = Uri.parse(callBackUrl);
      final response = await http.post(
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
    } catch (e) {
      // print("Error getting history: $e");
    }
    return false;
  }

  Future extendReserveCallback(String callBackUrl) async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    try {
      final url = Uri.parse(callBackUrl);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return json;
      } else {
        return false;
      }
    } catch (e) {
      // print("Error getting history: $e");
    }
    return false;
  }
}
