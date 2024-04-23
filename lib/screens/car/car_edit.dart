import 'package:flutter/material.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/screens/logged-in/index.dart';
import '../../assets/colors/constant.dart';

class CarEditPage extends StatefulWidget {
  const CarEditPage(
      {super.key,
      required this.carID,
      required this.initialCarName,
      required this.initialLicensePlate,
      required this.initialBrand,
      required this.initialModel,
      required this.initialColor,
      required this.onEdit});
  final String carID;
  final String initialCarName;
  final String initialLicensePlate;
  final String initialBrand;
  final String initialModel;
  final String initialColor;
  final VoidCallback onEdit;
  @override
  CarEditPageState createState() => CarEditPageState();
}

class CarEditPageState extends State<CarEditPage> {
  final storage = const FlutterSecureStorage();
  final List<String> brands = ['Toyota', 'Honda', 'Nissan', 'BMW', 'Ford'];

  final List<String> colors = ['Red', 'Blue', 'Green', 'White', 'Black'];

  late TextEditingController carNameController;
  late TextEditingController licensePlateController;
  TextEditingController modalController = TextEditingController();

  String? selectedBrand;
  String? selectedModel;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    carNameController = TextEditingController(text: widget.initialCarName);
    licensePlateController =
        TextEditingController(text: widget.initialLicensePlate);
    selectedBrand = widget.initialBrand;
    modalController = TextEditingController(text: widget.initialModel);
    selectedColor = widget.initialColor;
  }

  void editCar(String name, String licensePlate, String brand, String model,
      String color, String carPictureUrl) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
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

        final url =
            Uri.parse('${dotenv.env['HOST']}/customer/car?_id=${widget.carID}');

        final response = await http.patch(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
            body: body);

        if (response.statusCode == 200) {
          widget.onEdit();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoggedInPage(screenIndex: 1)));
        } else {
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
        title: const Text('แก้ไขข้อมูลของรถ'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: carNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อรถ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: licensePlateController,
              decoration: const InputDecoration(
                labelText: 'ป้ายทะเบียน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // ฟิลด์ยี่ห้อ, รุ่น, สี ตามเดิม
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
            // ...
            const SizedBox(height: 40),
            Center(
              child: PurpleButton(
                label: 'บันทึก',
                onPressed: () {
                  editCar(
                      carNameController.text,
                      licensePlateController.text,
                      selectedBrand!,
                      modalController.text,
                      selectedColor!,
                      "fff");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
