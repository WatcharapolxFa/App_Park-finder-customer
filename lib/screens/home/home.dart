// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/screens/parking/favorite_car_park.dart';
import 'package:parkfinder_customer/services/history_service.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/class_components.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/screens/reward/reward_screen.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:parkfinder_customer/screens/logged-in/index.dart';
import 'package:parkfinder_customer/screens/search/filter.dart';
import 'package:parkfinder_customer/widgets/car/car_card_add_home.dart';
import 'package:parkfinder_customer/widgets/car/car_card_home.dart';
import 'package:parkfinder_customer/widgets/history/history_card_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkfinder_customer/models/history_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  final historyService = HistoryService();
  final reserveService = ReserveService();
  late Position _currentPosition;
  List<Cars> carsList = [];
  List<History> historyList = [];
  late String paymentUrl;
  bool _isLoading = false;
  bool _isLoadPosition = false;
  bool _isClickToFilterNow = false;
  bool _isClickToFilterAdv = false;

  @override
  void initState() {
    super.initState();
    getPosition();
    loadHistory("on_working");
  }

  Future<void> getPosition() async {
    setState(() {
      _isLoadPosition = true;
    });
    _currentPosition = await _determinePosition();
    if (!mounted) return;
    setState(() {
      _isLoadPosition = false;
    });
    if (_isClickToFilterNow) {
      final fine = await reserveService.checkFine();
      EasyLoading.dismiss();
      if (fine == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FilterScreen(
                    currentPosition: _currentPosition,
                    isBookingNow: true,
                  )),
        );
      }
    } else if (_isClickToFilterAdv) {
      final fine = await reserveService.checkFine();
      EasyLoading.dismiss();
      if (fine == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FilterScreen(
                    currentPosition: _currentPosition,
                    isBookingNow: false,
                  )),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<List<Cars>> getCars() async {
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
          // throw Exception('Failed to load car information');
        }
      } catch (e) {
        // Failed to load data from Backend
        return [];
      }
    }

    return [];
  }

  Future<List<String>?> getCachedCars() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cachedCars');
  }

  Future<void> cacheCars(List<Cars> carsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        carsList.map((car) => json.encode(car.toJson())).toList();
    prefs.setStringList('cachedCars', jsonList);
  }

  Future<List<History>> loadHistory(String status) async {
    setState(() {
      _isLoading = true;
    });
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final histories = await historyService.getHistory(status, accessToken);
      if (!mounted) return [];
      setState(() {
        historyList = histories;
        _isLoading = false;
      });
      return histories;
    } else {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon couponIcon = const Icon(
      Icons.local_offer,
      color: AppColor.appPrimaryColor,
    );
    Icon heartIcon = const Icon(
      Icons.favorite,
      color: AppColor.appPrimaryColor,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0), // เพิ่ม padding 20
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35), // This is already const.
            Row(
              children: [
                const Text(
                  "กำลังหาที่จอดอยู่ใช่ไหม",
                  style: TextStyle(fontSize: 20),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RewardScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                    child: couponIcon,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoriteCarParkScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                    child: heartIcon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("เราช่วยคุณได้ !",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (_isLoadPosition) {
                        EasyLoading.show();
                        setState(() {
                          _isClickToFilterNow = true;
                        });
                      } else {
                        final fine = await reserveService.checkFine();
                        EasyLoading.dismiss();
                        if (fine == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FilterScreen(
                                      currentPosition: _currentPosition,
                                      isBookingNow: true,
                                    )),
                          );
                        }
                      }
                    },
                    child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "จองตอนนี้",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Icon(
                              Icons.book,
                              color: AppColor.appPrimaryColor,
                              size: 40,
                            )
                          ],
                        )),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (_isLoadPosition) {
                        EasyLoading.show();
                        setState(() {
                          _isClickToFilterAdv = true;
                        });
                      } else {
                        final fine = await reserveService.checkFine();
                        EasyLoading.dismiss();
                        if (fine == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FilterScreen(
                                      currentPosition: _currentPosition,
                                      isBookingNow: false,
                                    )),
                          );
                        }
                      }
                    },
                    child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "จองล่วงหน้า",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Icon(
                              Icons.calendar_month,
                              color: AppColor.appPrimaryColor,
                              size: 40,
                            )
                          ],
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CupertinoPopupSurface(
                isSurfacePainted: false,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            Visibility(
              visible: historyList.isNotEmpty,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("การจองของฉัน",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Visibility(
              visible: historyList.isNotEmpty,
              child: historyList.isNotEmpty
                  ? HistoryCardHome(history: historyList[0])
                  : Container(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("รถของฉัน",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const LoggedInPage(screenIndex: 1),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: FutureBuilder(
                      future: getCars(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data!.isEmpty) {
                          return carCardAddHome(); // Show Add Car widget
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
                          return CarCardHome(car: carsList[0]);
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
