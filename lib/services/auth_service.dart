import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AuthService {
  String? accessToken;
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );
  Future<bool> signInWithAPI(String email, String password) async {
    Map data = {'Email': email, 'Password': password};
    String body = json.encode(data);

    final url = Uri.parse('${dotenv.env['HOST']}/customer/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _logger.d(data);
      accessToken = data['access_token'];
      return true;
    } else {
      _logger.e('Failed to connect to API: ${response.body}');
      return false;
    }
  }
}
