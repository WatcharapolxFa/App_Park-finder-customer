import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:parkfinder_customer/widgets/class_components.dart';
import 'package:parkfinder_customer/screens/reserve/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ParkingSummary extends StatefulWidget {
  const ParkingSummary(
      {super.key,
      required this.parkingID,
      required this.providerID,
      required this.parkingName,
      required this.parkingAddress,
      required this.startDate,
      required this.endDate,
      required this.entryTime,
      required this.exitTime,
      required this.price,
      required this.cashback,
      required this.quantity,
      required this.sumPrice});
  final String parkingID;
  final String providerID;
  final String parkingName;
  final String parkingAddress;
  final String startDate;
  final String endDate;
  final TimeOfDay entryTime;
  final TimeOfDay exitTime;
  final int price;
  final int cashback;
  final double quantity;
  final int sumPrice;
  @override
  ParkingSummaryState createState() => ParkingSummaryState();
}

class ParkingSummaryState extends State<ParkingSummary> {
  List<Cars> carsList = [];
  int cashbackUsed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.cashback > 0) {
      if (widget.cashback >= widget.sumPrice) {
        cashbackUsed = widget.sumPrice;
      } else {
        cashbackUsed = widget.cashback;
      }
    }
  }

  Future<List<Cars>> getCars() async {
    List<String>? cachedCars = await getCachedCars();
    if (cachedCars != null && cachedCars.isNotEmpty) {
      return cachedCars
          .map((jsonString) => Cars.fromJson(json.decode(jsonString)))
          .toList();
    }
    return [];
  }

  Future<List<String>?> getCachedCars() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cachedCars');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appPrimaryColor,
          title: Text(widget.parkingName,
              style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ข้อมูลการจอด',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                const SizedBox(height: 10),
                Card(
                  // elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parkingName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.parkingAddress),
                        const SizedBox(height: 10),
                        const Divider(),
                        const Text(
                          'รถของคุณ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder(
                            future: getCars(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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

                                return CarCard(car: carsList[0]);
                              }
                            }),
                        const SizedBox(height: 20),
                        const Divider(),
                        Center(
                          child: Column(
                            children: [
                              const Text('PARKFINDER',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              const Divider(
                                  color: Colors.deepPurple, thickness: 2),
                              const SizedBox(height: 20),
                              _InfoRow(
                                  title: 'วันที่เริ่มการจอง',
                                  info: widget.startDate),
                              _InfoRow(
                                  title: 'เวลาเข้าจอด',
                                  info:
                                      '${widget.entryTime.hour.toString().padLeft(2, '0')}:${widget.entryTime.minute.toString().padLeft(2, '0')} น.'),
                              _InfoRow(
                                  title: 'วันที่จบการจอง',
                                  info: widget.endDate),
                              _InfoRow(
                                  title: 'เวลาออก',
                                  info:
                                      '${widget.exitTime.hour.toString().padLeft(2, '0')}:${widget.exitTime.minute.toString().padLeft(2, '0')} น.'),
                              const Divider(),
                              _InfoRow(
                                  title: 'ค่าจอดรถ',
                                  info: '${widget.sumPrice} บาท'),
                              Container(
                                child: widget.cashback > 0
                                    ? _InfoRow(
                                        title:
                                            'เงินภายในแอป (คงเหลือ ${NumberFormat("#,##0", "en_US").format(widget.cashback)} บาท)',
                                        info: '-$cashbackUsed บาท',
                                        textColor: Colors.red,
                                      )
                                    : Container(),
                              ),
                              const Divider(),
                              _InfoRow(
                                  title: 'รวม',
                                  info: '${widget.sumPrice - cashbackUsed} บาท',
                                  style: FontWeight.bold),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: PurpleButton(
                    label: "ชำระเงิน",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                              parkingID: widget.parkingID,
                              providerID: widget.providerID,
                              parkingName: widget.parkingName,
                              carID: carsList[0].carID,
                              startDate: widget.startDate,
                              endDate: widget.endDate,
                              entryTime: widget.entryTime,
                              exitTime: widget.exitTime,
                              sumPrice: widget.sumPrice,
                              quantity: widget.quantity,
                              price: widget.price,
                              cashbackUsed: cashbackUsed),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.info,
    this.textColor,
    this.style,
  });

  final String title;
  final String info;
  final Color? textColor;
  final FontWeight? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16.0, fontWeight: style ?? FontWeight.normal)),
          Text(info,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: style ?? FontWeight.normal,
                  color: textColor ?? Colors.black)),
        ],
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  final Cars car;

  const CarCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        car.licensePlate,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  car.carDefault
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 28,
                  color: AppColor.appPrimaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
