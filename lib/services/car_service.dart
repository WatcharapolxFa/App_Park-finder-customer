import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parkfinder_customer/widgets/class_components.dart';

class CarService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<List<Cars>> getCars() async {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final url = Uri.parse('${dotenv.env['HOST']}/customer/car');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body)['data'];
      if (jsonList.isEmpty) {
        throw Exception('Data not found');
      }
      return jsonList.map((json) => Cars.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load car data');
    }
  }

  // ฟังก์ชันเพิ่ม, ลบ, อัปเดตข้อมูลรถยนต์ ฯลฯ
}
