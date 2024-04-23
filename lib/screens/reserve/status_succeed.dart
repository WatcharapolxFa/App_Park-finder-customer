import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';

class StatusSucceedScreen extends StatelessWidget {
  const StatusSucceedScreen({super.key, this.extend});
  final bool? extend;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/status_success.png',
                  width: 241,
                  height: 241,
                ),
                const SizedBox(height: 20.0),
                Text(
                  extend == null ? "การจองสำเร็จ" : "ขยายเวลาสำเร็จ",
                  style: const TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: AppColor.appPrimaryColor,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'ธุรกรรมการชำระเงินของคุณสำเร็จแล้ว',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFFA6AAB4),
                  ),
                ),
                const SizedBox(height: 100.0),
                const SizedBox(height: 100.0),
                PurpleButton(
                  label: 'กลับสู่หน้าหลัก',
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacementNamed(context, '/logged_in');
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
