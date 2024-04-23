import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/screens/myaddress/my_address_add.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../assets/colors/constant.dart';

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});
  @override
  MyAddressPageState createState() => MyAddressPageState();
}

class MyAddressPageState extends State<MyAddressPage> {
  final storage = const FlutterSecureStorage();

  List<dynamic> address = [];
  @override
  void initState() {
    super.initState();
    getAddress();
  }

  Future<void> getAddress() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        final url = Uri.parse('${dotenv.env['HOST']}/customer/address');
        final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            address = jsonDecode(response.body.toString())['address'];
          });
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

  void deleteAddress(addressID) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        if (addressID != null) {
          final url = Uri.parse(
              '${dotenv.env['HOST']}/customer/address?_id=$addressID');
          final response = await http.delete(
            url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
          );
          if (response.statusCode == 200) {
          } else {}
        }
      } catch (e) {
        // Failed to load data from Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
  }

  void defaultAddress(addressID) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        if (addressID != null) {
          final url = Uri.parse(
              '${dotenv.env['HOST']}/customer/address_default?_id=$addressID');
          final response = await http.patch(
            url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
          );
          if (response.statusCode == 200) {
          } else {}
        }
      } catch (e) {
        // Failed to load data from Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
  }

  List<Widget> getField() {
    final List<Widget> result = <Widget>[];

    for (var element in address) {
      IconData? iconShow;
      if (element['location_name'] == 'บ้าน') {
        iconShow = Icons.home;
      } else if (element['location_name'] == 'ที่ทำงาน') {
        iconShow = Icons.business;
      } else {
        iconShow = Icons.place;
      }
      result.add(SizedBox(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 3))
                  ],
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(
                          iconShow,
                          color: AppColor.appPrimaryColor,
                        ),
                        const SizedBox(
                          width: 2.5,
                        ),
                        Text(
                          "${element['location_name']} ${element['default'] ? '(Default)' : ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                  "${element['address_text']} ${element['sub_district']} ${element['district']} ${element['province']} ${element['postal_code']}",
                                  style: const TextStyle(height: 1.5)),
                            ),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: 200,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  iconShow,
                                                  color:
                                                      const Color(0xFF6828DC),
                                                ),
                                                const SizedBox(
                                                  width: 2.5,
                                                ),
                                                Text(
                                                  element['location_name'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                defaultAddress(
                                                    element['address_id']);
                                                Navigator.pop(context);
                                                getAddress();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.star_rounded),
                                                    SizedBox(
                                                      width: 2.5,
                                                    ),
                                                    Text('Make default')
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyAddressAddPage(
                                                      type: 'edit',
                                                      id: element['address_id'],
                                                      locationName: element[
                                                          'location_name'],
                                                      address:
                                                          "${element['address_text']} ${element['sub_district']} ${element['district']} ${element['province']} ${element['postal_code']}",
                                                      latlong: LatLng(
                                                          element['latitude'],
                                                          element['longitude']),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit),
                                                    SizedBox(
                                                      width: 2.5,
                                                    ),
                                                    Text('Edit')
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                deleteAddress(
                                                    element['address_id']);
                                                Navigator.pop(context);
                                                getAddress();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.blind),
                                                    SizedBox(
                                                      width: 2.5,
                                                    ),
                                                    Text('Delete')
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColor.appPrimaryColor,
                              ),
                            )
                          ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ));
    }
    result.add(Container(
      height: 45,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 5,
                color: Colors.grey.withOpacity(0.5),
                offset: const Offset(0, 3))
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyAddressAddPage()),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
              ),
              Text('เพิ่มที่อยู่ใหม่'),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    ));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ที่อยู่ของฉัน'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6828DC),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getAddress,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                children: [
                  Column(
                    children: getField(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
