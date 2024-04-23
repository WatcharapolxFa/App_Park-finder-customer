import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/widgets/class_components.dart';
import 'package:parkfinder_customer/screens/car/car_edit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarCardWidget extends StatefulWidget {
  const CarCardWidget(
      {super.key,
      required this.car,
      required this.onDelete,
      required this.onEdit});
  final Cars car;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  CarCardWidgetState createState() => CarCardWidgetState();
}

class CarCardWidgetState extends State<CarCardWidget> {
  final storage = const FlutterSecureStorage();

  Future<void> chageDefaultCar(String carID) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final url =
            Uri.parse('${dotenv.env['HOST']}/customer/car_default?_id=$carID');

        final response = await http.patch(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );

        if (response.statusCode == 200) {
          widget.onEdit();
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

  Future<void> deleteCar(String carID) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final url = Uri.parse('${dotenv.env['HOST']}/customer/car?_id=$carID');

        final response = await http.delete(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
        );

        if (response.statusCode == 200) {
          widget.onDelete();
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.car.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.grey),
                    title: const Text('Make default'),
                    onTap: () async {
                      await chageDefaultCar(widget.car.carID);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.grey),
                    title: const Text('แก้ไขข้อมูล'),
                    onTap: () {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CarEditPage(
                                    carID: widget.car.carID,
                                    initialCarName: widget.car.name,
                                    initialLicensePlate:
                                        widget.car.licensePlate,
                                    initialBrand: widget.car.brand,
                                    initialModel: widget.car.model,
                                    initialColor: widget.car.color,
                                    onEdit: () {
                                      widget.onEdit();
                                    },
                                  )));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.grey),
                    title: const Text('ลบ'),
                    onTap: () async {
                      await deleteCar(widget.car.carID);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Image.asset(
                'lib/assets/images/car-b.png',
                width: 100,
                height: 100,
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.car.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.car.licensePlate,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
                  Icon(
                    widget.car.carDefault
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 28,
                    color: AppColor.appPrimaryColor,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
