import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/screens/parking/favorite_car_park.dart';
import 'package:parkfinder_customer/screens/profile/profile_edit.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:parkfinder_customer/screens/reward/reward_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/buttons/button_purple.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final logger = Logger();
  final storage = const FlutterSecureStorage();

  Map<String, dynamic> profile = {
    'profile_picture_url': '',
    'first_name': '',
    'last_name': '',
    'email': ''
  };

  @override
  void initState() {
    super.initState();
    initProfile();
    getProfile();
  }

  void initProfile() async {
    String? firstName = await storage.read(key: 'firstName');
    String? lastName = await storage.read(key: 'lastName');
    String? email = await storage.read(key: 'email');
    String? pictureURL = await storage.read(key: 'pictureURL');
    setState(() {
      profile = {
        'profile_picture_url': pictureURL,
        'first_name': firstName,
        'last_name': lastName,
        'email': email
      };
    });
  }

  void getProfile() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final url = Uri.parse('${dotenv.env['HOST']}/customer/profile');
        final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            profile = jsonDecode(response.body.toString())['profile'];
          });
          String? firstName = await storage.read(key: 'firstName');
          String? lastName = await storage.read(key: 'lastName');
          String? email = await storage.read(key: 'email');
          String? pictureURL = await storage.read(key: 'pictureURL');

          if (profile['first_name'] != firstName) {
            await storage.write(key: 'firstName', value: profile['first_name']);
          }
          if (profile['last_name'] != lastName) {
            await storage.write(key: 'lastName', value: profile['last_name']);
          }
          if (profile['email'] != email) {
            await storage.write(key: 'email', value: profile['email']);
          }
          if (profile['profile_picture_url'] != pictureURL) {
            await storage.write(
                key: 'pictureURL', value: profile['profile_picture_url']);
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        // Failed to load data from Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: profile['profile_picture_url'] == ""
                  ? Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: const Icon(Icons.person, size: 30),
                    )
                  : Image.network(
                      (profile['profile_picture_url']),
                      key: ValueKey(Random().nextInt(100)),
                      fit: BoxFit.fill,
                      width: 60,
                      height: 60,
                    ),
            ),
            title: Text('${profile['first_name']} ${profile['last_name']}'),
            subtitle: Text('${profile['email']}'),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditPage(
                    profileID: profile['_id'],
                    name: profile['first_name'],
                    lastName: profile['last_name'],
                    phoneNumber: profile['phone'],
                    idCard: profile['ssn'],
                    birthDay: profile['birth_day'],
                    profileURL: profile['profile_picture_url'],
                    onEdit: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
            child: const ListTile(
              title: Text('แก้ไขโปรไฟล์ส่วนตัว'),
              trailing: Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RewardScreen()));
            },
            child: const ListTile(
              title: Text('คูปอง'),
              trailing: Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteCarParkScreen()));
            },
            child: const ListTile(
              title: Text('ที่จอดรถโปรด'),
              trailing: Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ),
          const SizedBox(height: 360),
          Center(
            child: PurpleButton(
              label: 'ออกจากระบบ',
              onPressed: () async {
                EasyLoading.show();
                const storage = FlutterSecureStorage();
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken != null) {
                  try {
                    final url =
                        Uri.parse('${dotenv.env['HOST']}/customer/logout');
                    final response = await http.post(
                      url,
                      headers: {
                        "Content-Type": "application/json",
                        'Authorization': 'Bearer $accessToken'
                      },
                    );

                    if (response.statusCode == 200) {
                      EasyLoading.dismiss();
                      await storage.deleteAll();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedCars');
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/welcome');
                    }
                    EasyLoading.dismiss();
                  } catch (e) {
                    // Failed to load data from Backend
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
