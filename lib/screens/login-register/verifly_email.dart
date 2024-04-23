import 'package:flutter/material.dart';
import 'package:parkfinder_customer/screens/login-register/login.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../assets/colors/constant.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  // Constructor to get the email from the previous page
  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  String otp = '';

  final otpController = TextEditingController();

  final textNode = FocusNode();

  final logger = Logger();

  final storage = const FlutterSecureStorage();

  bool _canResendOTP = true;
  // ตัวแปรติดตามสถานะปุ่ม
  Timer? _timer;
  // Timer สำหรับนับถอยหลัง
  @override
  void initState() {
    super.initState();
    otp = '';
  }

  void onOtpInput(String value) {
    setState(() {
      otp = value;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel(); // ยกเลิก Timer เก่าหากมีการกดซ้ำ
    }
    setState(() => _canResendOTP = false);
    _timer = Timer(const Duration(seconds: 30), () {
      setState(() => _canResendOTP = true);
    });
  }

  Future<void> resendOTP() async {
    final String email = widget.email; // ใช้ email จาก widget
    Map data = {'email': email};
    String body = json.encode(data);

    final url = Uri.parse('${dotenv.env['HOST']}/customer/resend_register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // ส่ง OTP ใหม่สำเร็จ
        EasyLoading.showInfo("ส่งอีเมลใหม่เรียบร้อย");
      } else {
        // การส่งไม่สำเร็จ
        EasyLoading.showInfo("ไม่สามารถส่งอีเมลใหม่ได้");
      }
    } catch (e) {
      // การเชื่อมต่อมีปัญหา
      EasyLoading.showError("ไม่สามารถส่งอีเมลใหม่ได้");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0), // เว้นขอบ 20 px
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColor.appPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        15.0), // ค่านี้ควบคุมความกลมของมุม
                  ),
                  child: const Icon(
                    Icons.email,
                    color: AppColor.appPrimaryColor,
                    size: 100.0,
                  ),
                ),
                const SizedBox(height: 20),

                // ข้อความ "ยืนยันการลงทะเบียน"
                const Text(
                  'ยืนยันการลงทะเบียน',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // แสดงอีเมลที่รับมา
                Text(
                  'อีเมล: ${widget.email}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                // ข้อความ "กรุณาคลิกลิงก์ในอีเมลเพื่อยืนยันการลงทะเบียน"
                const Text(
                  'กรุณาคลิกลิงก์ในอีเมลเพื่อยืนยันการลงทะเบียน',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 360),

                // ปุ่มกลับหน้าเข้าสู่ระบบ
                PurpleButton(
                  label: 'กลับหน้าเข้าสู่ระบบ',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ไม่ได้รับ Email ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _canResendOTP
                          ? () {
                              _startTimer();
                              resendOTP();
                            }
                          : null,
                      child: Text(
                        'ส่งอีกครั้ง',
                        style: TextStyle(
                          color: _canResendOTP
                              ? AppColor.appPrimaryColor
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
