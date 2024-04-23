import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/screens/myaddress/my_address_map.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../assets/colors/constant.dart';

class MyAddressAddPage extends StatefulWidget {
  const MyAddressAddPage({
    super.key,
    this.address,
    this.latlong,
    this.id,
    this.type,
    this.locationName,});
  final String? address;
  final LatLng? latlong;
  final String? id;
  final String? type;
  final String? locationName;

  @override
  MyAddressAddPageState createState() => MyAddressAddPageState();
}

class MyAddressAddPageState extends State<MyAddressAddPage> {
  final storage = const FlutterSecureStorage();

  int selectedButtonIndex = -1;
  String? locationName;
  final textController = TextEditingController();
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    if (widget.locationName != null) {
      if (widget.locationName == 'บ้าน') {
        selectedButtonIndex = 1;
      } else if (widget.locationName == 'ที่ทำงาน') {
        selectedButtonIndex = 2;
      } else {
        selectedButtonIndex = 3;
        textController.text = widget.locationName ?? '';
      }
    }
  }

  void handleButtonTap(int index) {
    setState(() {
      selectedButtonIndex = index;
    });
  }

  void onTextChange(String value) {
    setState(() {
      locationName = value;
    });
  }

  Future<Map<String, dynamic>> saveAddress() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        Map data = {
          'address': widget.address,
          'location_name': locationName,
          'latitude': widget.latlong?.latitude,
          'longitude': widget.latlong?.longitude
        };
        String body = json.encode(data);

        late http.Response response;

        if (widget.id != null) {
          final url = Uri.parse(
              '${dotenv.env['HOST']}/customer/address?_id=${widget.id}');
          response = await http.patch(
            url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
            body: body,
          );
        } else {
          final url = Uri.parse('${dotenv.env['HOST']}/customer/address');
          response = await http.post(
            url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
            body: body,
          );
        }

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          _logger.d(data);
          return {'success': true, 'responseBody': response.body};
        } else {
          _logger.e('Failed to connect to API: ${response.body}');
          return {'success': false, 'responseBody': response.body};
        }
      } catch (e) {
        return {'success': false, 'responseBody': ''};
        // Failed to connect Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
    return {'success': false, 'responseBody': ''};
  }

  bool? saveSuccess;
  String? responseBody;

  void handleSaveAddress() async {
    final response = await saveAddress();
    Map<String, dynamic> jsonMap = json.decode(response['responseBody']);
    setState(() {
      saveSuccess = response['success'];
      responseBody = jsonMap['message'];
    });
  }

  void proceedAfterSaveAddress(BuildContext context, bool success) {
    if (success) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/my_address', ModalRoute.withName('/logged_in'));
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Failed to connect to API'),
          content: Text(responseBody!),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (saveSuccess != null) {
        proceedAfterSaveAddress(context, saveSuccess!);
        saveSuccess = null;
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('ที่อยู่ของฉัน'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ที่อยู่',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 3))
                          ],
                          color: AppColor.appPrimaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyAddressMapPage(
                                      addressR: widget.address,
                                      latlongR: widget.latlong,
                                    )),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.place,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  widget.address ?? 'เพิ่มที่อยู่ใหม่',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ประเภทที่อยู่',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: const Offset(0, 3))
                              ],
                              color: selectedButtonIndex == 1
                                  ? AppColor.appPrimaryColor
                                  : Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: InkWell(
                            onTap: () {
                              handleButtonTap(1);
                              setState(() {
                                locationName = 'บ้าน';
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.home,
                                    color: selectedButtonIndex == 1
                                        ? Colors.white
                                        : AppColor.appPrimaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'บ้าน',
                                    style: TextStyle(
                                        color: selectedButtonIndex == 1
                                            ? Colors.white
                                            : AppColor.appPrimaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: const Offset(0, 3))
                              ],
                              color: selectedButtonIndex == 2
                                  ? AppColor.appPrimaryColor
                                  : Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: InkWell(
                            onTap: () {
                              handleButtonTap(2);
                              setState(() {
                                locationName = 'ที่ทำงาน';
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: selectedButtonIndex == 2
                                        ? Colors.white
                                        : AppColor.appPrimaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'ทีทำงาน',
                                    style: TextStyle(
                                        color: selectedButtonIndex == 2
                                            ? Colors.white
                                            : AppColor.appPrimaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: const Offset(0, 3))
                              ],
                              color: selectedButtonIndex == 3
                                  ? AppColor.appPrimaryColor
                                  : Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: InkWell(
                            onTap: () {
                              handleButtonTap(3);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: selectedButtonIndex == 3
                                        ? Colors.white
                                        : AppColor.appPrimaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'อื่น ๆ',
                                    style: TextStyle(
                                        color: selectedButtonIndex == 3
                                            ? Colors.white
                                            : AppColor.appPrimaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                    visible: selectedButtonIndex == 3,
                    child: TextFormField(
                        controller: textController,
                        onChanged: onTextChange,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อที่อยู่',
                          border: OutlineInputBorder(),
                        ))),
                SizedBox(
                  height: selectedButtonIndex == 3 ? 300 : 359,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            color: Colors.grey.withOpacity(0.5),
                            offset: const Offset(0, 3))
                      ],
                      color: AppColor.appPrimaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: InkWell(
                      onTap: () {
                        handleSaveAddress();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'บันทึก',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
