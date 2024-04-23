import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/services/reward_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import '../../assets/colors/constant.dart';
import 'reward_confirm.dart';

class ClaimRewardScreen extends StatefulWidget {
  const ClaimRewardScreen({
    super.key,
    required this.rewardID,
    required this.title,
    required this.description,
    required this.expiredDate,
    required this.imageURL,
    required this.condition,
    required this.point,
    required this.profilePoint,
  });

  final String rewardID;
  final String title;
  final String description;
  final String expiredDate;
  final String imageURL;
  final List<String> condition;
  final int point;
  final int profilePoint;

  @override
  ClaimRewardState createState() => ClaimRewardState();
}

class ClaimRewardState extends State<ClaimRewardScreen> {
  final rewardService = RewardService();

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
                      'หมดอายุ ${DateFormat('d/MM/yyyy').format(DateTime.parse(widget.expiredDate))}',
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
                    const SizedBox(height: 30),
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
                      child: PurpleButton(
                        label: 'แลก ${widget.point} คะแนน',
                        onPressed: () async {
                          if (widget.profilePoint >= widget.point) {
                            var response = await rewardService
                                .redeemReward(widget.rewardID);
                            if (response.isNotEmpty) {
                              var barcodeURL =
                                  response['message'].toString().split("?");
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RewardConfirmScreen(
                                          barcodeURL: barcodeURL[0],
                                          rewardID: widget.rewardID,
                                          condition: widget.condition,
                                          description: widget.description,
                                          expiredDate: widget.expiredDate,
                                          imageURL: widget.imageURL,
                                          point: widget.point,
                                          title: widget.title,
                                        )),
                              );
                            }
                          } else {
                            EasyLoading.showError("Point ไม่เพียงพอ");
                          }
                        },
                      ),
                    ),
                    const Text(
                      'หลังจากแลกรางวัลแล้ว จะใช้ได้ภายใน 24 ชั่วโมง',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 0, 0, 0),
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
