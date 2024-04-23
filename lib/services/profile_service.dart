import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:parkfinder_customer/models/profile_modal.dart';

class ProfileService {
  final FlutterSecureStorage _storage;
  final String? _apiHost;

  ProfileService()
      : _storage = const FlutterSecureStorage(),
        _apiHost = dotenv.env['HOST'];

  Future<Profile?> getProfile() async {
    String? accessToken = await _storage.read(key: 'accessToken');
    if (accessToken != null) {
      Profile profile;
      try {
        final url = Uri.parse('$_apiHost/customer/profile');
        final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body)['profile'];
          profile = Profile.fromJson(json);
          await updateProfile(profile);
          return profile;
        }
      } catch (e) {
        // Handle error
      }
    }
    return null;
  }

  Future<void> updateProfile(Profile profileData) async {
    String? firstName = await _storage.read(key: 'firstName');
    String? lastName = await _storage.read(key: 'lastName');
    String? email = await _storage.read(key: 'email');
    String? pictureURL = await _storage.read(key: 'pictureURL');

    if (profileData.firstName != firstName) {
      await _storage.write(key: 'firstName', value: profileData.firstName);
    }
    if (profileData.lastName != lastName) {
      await _storage.write(key: 'lastName', value: profileData.lastName);
    }
    if (profileData.email != email) {
      await _storage.write(key: 'email', value: profileData.email);
    }
    if (profileData.profilePictureURL != pictureURL) {
      await _storage.write(
          key: 'pictureURL', value: profileData.profilePictureURL);
    }
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: 'accessToken');
  }
}
