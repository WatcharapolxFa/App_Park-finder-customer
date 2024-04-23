import 'package:parkfinder_customer/models/history_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryService {
  Future<List<History>> getHistory(String status, String accessToken) async {
    List<History> historyList = [];
    try {
      Map data = {
        "status": status,
        "parking_id": "",
      };
      String body = json.encode(data);
      final url = Uri.parse('${dotenv.env['HOST']}/customer/my_reserve');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
        body: body,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body)['data'];
        historyList = jsonList.map((json) => History.fromJson(json)).toList();
      }
    } catch (e) {
      // print(e);
    }
    return historyList;
  }
}
