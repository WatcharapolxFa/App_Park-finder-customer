import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/screens/logged-in/index.dart';

class CarAddPage extends StatefulWidget {
  const CarAddPage({super.key, required this.onAdd});
  final VoidCallback onAdd;
  @override
  CarAddPageState createState() => CarAddPageState();
}

class CarAddPageState extends State<CarAddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController modalController = TextEditingController();

  final storage = const FlutterSecureStorage();
  final List<String> brands = ['Toyota', 'Honda', 'Nissan', 'BMW', 'Ford'];

  final List<String> colors = ['Red', 'Blue', 'Green', 'White', 'Black'];

  String? selectedBrand;
  String? selectedModel;
  String? selectedColor;

  void addMyCar(String name, String licensePlate, String brand, String model,
      String color, String carPictureUrl) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      EasyLoading.show();
      try {
        Map data = {
          'name': name,
          'license_plate': licensePlate,
          'brand': brand,
          'model': model,
          'color': color,
          'car_picture_url': carPictureUrl
        };
        String body = json.encode(data);

        final url = Uri.parse('${dotenv.env['HOST']}/customer/car');

        final response = await http.post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
            body: body);

        if (response.statusCode == 200) {
          EasyLoading.dismiss();
          widget.onAdd();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoggedInPage(screenIndex: 1)));
        } else {
          EasyLoading.dismiss();
          // _logger.e('Failed to connect to API: ${response.body}');
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
        title: const Text('เพิ่มข้อมูลของรถ'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ชื่อรถ',
                  border: OutlineInputBorder(),
                ),
                controller: nameController,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ป้ายทะเบียน',
                  border: OutlineInputBorder(),
                ),
                controller: licensePlateController,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                items: brands.map((String brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                  });
                },
                value: selectedBrand,
                decoration: const InputDecoration(
                  labelText: 'ยี่ห้อ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'รุ่นรถ',
                  border: OutlineInputBorder(),
                ),
                controller: modalController,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                items: colors.map((String color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                  });
                },
                value: selectedColor,
                decoration: const InputDecoration(
                  labelText: 'สี',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: PurpleButton(
                  label: 'บันทึก',
                  onPressed: () {
                    addMyCar(
                        nameController.text,
                        licensePlateController.text,
                        selectedBrand!,
                        modalController.text,
                        selectedColor!,
                        "test.com");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
