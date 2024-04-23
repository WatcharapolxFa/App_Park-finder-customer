import 'package:flutter/material.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/widgets/car/car_card.dart';
import 'package:parkfinder_customer/widgets/class_components.dart';
import 'package:parkfinder_customer/screens/car/car_add.dart';
import '../../assets/colors/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});
  @override
  CarListPageState createState() => CarListPageState();
}

class CarListPageState extends State<CarListPage> {
  final storage = const FlutterSecureStorage();
  List<Cars> carsList = [];

  Future<List<Cars>> getCars() async {
    // bool? cachedCarsCheck = await getCachedCarsCheck();
    // if (cachedCarsCheck != null && cachedCarsCheck == true) { }
    List<String>? cachedCars = await getCachedCars();
    if (cachedCars != null && cachedCars.isNotEmpty) {
      return cachedCars
          .map((jsonString) => Cars.fromJson(json.decode(jsonString)))
          .toList();
    }

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        final url = Uri.parse('${dotenv.env['HOST']}/customer/car');
        final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body.toString())['data'];
          List<Cars> carsList =
              jsonList.map((json) => Cars.fromJson(json)).toList();

          await cacheCars(carsList);
          return carsList;
        } else {
          await setCacheCarsCheck(true);
          // throw Exception('Failed to load car information');
        }
      } catch (e) {
        // Failed to load data from Backend
        return [];
      }
    }

    return [];
  }

  Future<bool?> getCachedCarsCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('cachedCarsCheck');
  }

  Future<List<String>?> getCachedCars() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cachedCars');
  }

  Future<void> cacheCars(List<Cars> carsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        carsList.map((car) => json.encode(car.toJson())).toList();
    await prefs.setStringList('cachedCars', jsonList);
  }

  Future<void> setCacheCarsCheck(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cachedCarsCheck', status);
  }

  Future<void> clearCachedCars() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedCars');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ข้อมูลของรถ"),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รถของฉัน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    FutureBuilder(
                        future: getCars(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                            // } else if (snapshot.data == null || snapshot.data.carName == null) {
                            // return AddCarWidget(); // Show Add Car widget
                          } else {
                            carsList = snapshot.data as List<Cars>;
                            carsList.sort((a, b) {
                              if (a.carDefault && !b.carDefault) {
                                return -1;
                              } else if (!a.carDefault && b.carDefault) {
                                return 1;
                              } else {
                                return 0;
                              }
                            });
                            return Column(
                              children: carsList.map((car) {
                                return Column(
                                  children: [
                                    CarCardWidget(
                                      car: car,
                                      onDelete: () {
                                        clearCachedCars();
                                        setState(() {
                                          carsList.remove(car);
                                        });
                                      },
                                      onEdit: () {
                                        clearCachedCars();
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 15)
                                  ],
                                );
                              }).toList(),
                            );
                          }
                        }),
                  ],
                ),
                const SizedBox(height: 15),
                Center(
                  child: PurpleButton(
                    label: 'เพิ่มรถ',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarAddPage(
                            onAdd: () {
                              clearCachedCars();
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
