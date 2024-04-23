import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/models/point_history_modal.dart';
import 'package:parkfinder_customer/models/reward_model.dart';
import 'package:logger/logger.dart';

class RewardService {
  final storage = const FlutterSecureStorage();
  final logger = Logger();

  Future<List<RewardDetail>> fetchRewards() async {
    String? accessToken = await storage.read(key: 'accessToken');
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['HOST']}/customer/reward'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rewardsJson = jsonDecode(response.body)['data'];
        return rewardsJson.map((json) => RewardDetail.fromJson(json)).toList();
      } else {
        logger.e('Failed to load rewards');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching rewards: $e');
      return [];
    }
  }

  Future<RewardDetail?> getRewardDetail(String rewardID) async {
    RewardDetail rewardDetail;
    String? accessToken = await storage.read(key: 'accessToken');
    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/reward_detail?_id=$rewardID');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['data'];
        rewardDetail = RewardDetail.fromJson(json);
        return rewardDetail;
      }
    } catch (e) {
      // print("Error getting parking: $e");
    }
    return null;
  }

  Future redeemReward(String rewardID) async {
    String? accessToken = await storage.read(key: 'accessToken');
    try {
      final url = Uri.parse(
          '${dotenv.env['HOST']}/customer/redeem_reward?_id=$rewardID');
      final response = await http.get(
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
        return response.body;
      }
    } catch (e) {
      return ("Error redeem reward: $e");
    }
  }

  Future<List<PointHistory>> getHistoryPoint() async {
    String? accessToken = await storage.read(key: 'accessToken');
    try {
      final url = Uri.parse('${dotenv.env['HOST']}/customer/history_point');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> historyJson = jsonDecode(response.body)['data'];
        return historyJson.map((json) => PointHistory.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<MyRewardDetail>> fetchMyRewards() async {
    String? accessToken = await storage.read(key: 'accessToken');
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['HOST']}/customer/my_redeem_reward'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rewardsJson = jsonDecode(response.body)['data'];
        return rewardsJson.map((json) => MyRewardDetail.fromJson(json)).toList();
      } else {
        logger.e('Failed to load my rewards');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching my rewards: $e');
      return [];
    }
  }
}
