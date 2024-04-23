import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/screens/reward/reward_screen.dart';
import '../../assets/colors/constant.dart';

class RewardConfirmScreen extends StatefulWidget {
  const RewardConfirmScreen({
    super.key,
    required this.barcodeURL,
    required this.rewardID,
    required this.title,
    required this.description,
    this.expiredDate,
    this.customerExpiredDate,
    required this.imageURL,
    required this.condition,
    required this.point,
  });
  final String barcodeURL;
  final String rewardID;
  final String title;
  final String description;
  final String? expiredDate;
  final int? customerExpiredDate;
  final String imageURL;
  final List<String> condition;
  final int point;

  @override
  RewardConfirmState createState() => RewardConfirmState();
}

class RewardConfirmState extends State<RewardConfirmScreen> {
  String _buildConditions(List<String> conditions) {
    String result = '';
    for (int i = 0; i < conditions.length; i++) {
      result += '${i + 1}. ${conditions[i]}\n';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const RewardScreen()));
          },
        ),
        title: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "คูปอง",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor, // ตรวจสอบว่าค่านี้ถูกต้อง
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 131, 86, 213),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'PARKFINDER\nREWARD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.expiredDate != null
                          ? 'หมดอายุ ${DateFormat('d/MM/yyyy').format(DateTime.parse(widget.expiredDate!))}'
                          : 'เหลือเวลาอีก ${widget.customerExpiredDate} ชั่วโมง',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.network(
                      widget.imageURL,
                      width: 315,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'เงื่อนไขการใช้คูปอง\n${_buildConditions(widget.condition)}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        child: Image.network(
                          widget.barcodeURL,
                          width: 315,
                          height: 150,
                        )),
                     Text(
                      widget.customerExpiredDate != null ? 'คูปองนี้ใช้ได้ภายใน ${widget.customerExpiredDate} ชั่วโมง' : 'คูปองนี้ใช้ได้ภายใน 23 ชั่วโมง',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
