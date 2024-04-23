import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/screens/login-register/new_password.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'dart:async';

import '../../assets/colors/constant.dart';

class AuthenticationResetPasswordScreen extends StatefulWidget {
  const AuthenticationResetPasswordScreen({super.key, required this.email});
  final String email;
  @override
  AuthenticationResetPasswordState createState() =>
      AuthenticationResetPasswordState();
}

class AuthenticationResetPasswordState
    extends State<AuthenticationResetPasswordScreen> {
  String otp = '';
  final otpController = TextEditingController();
  final textNode = FocusNode();
  final logger = Logger();
  final storage = const FlutterSecureStorage();
  bool _canResendOTP = true; // ตัวแปรติดตามสถานะปุ่ม
  Timer? _timer;

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

  Future<String?> registerCustomer() async {
    Map data = {'Email': widget.email, 'OTP': otp};
    String body = json.encode(data);

    final url = Uri.parse('${dotenv.env['HOST']}/customer/verify_otp_forgot');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null; // ไม่สำเร็จ
      }
    } catch (error) {
      logger.i('Error connecting to API: $error');
      return null;
    }
  }

  Future<void> resendOTP() async {
    final String email = widget.email; // ใช้ email จาก widget
    Map data = {'email': email};
    String body = json.encode(data);

    final url = Uri.parse('${dotenv.env['HOST']}/customer/resend_forgot_otp');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // ส่ง OTP ใหม่สำเร็จ
        EasyLoading.showInfo("ส่ง OTP ใหม่เรียบร้อย");
      } else {
        // การส่งไม่สำเร็จ
        EasyLoading.showInfo("ไม่สามารถส่ง OTP ใหม่ได้");
      }
    } catch (e) {
      // การเชื่อมต่อมีปัญหา
      EasyLoading.showError("ไม่สามารถส่ง OTP ใหม่ได้");
    }
  }

  Future<void> handleVerify() async {
    final result = await registerCustomer();

    // เช็คว่า context ยังมีอยู่หรือไม่ก่อนทำการใช้งาน
    if (!mounted) return;

    setState(() {
      otp = '';
      otpController.clear();
      textNode.unfocus();
    });

    if (result != null) {
      // ส่งอีเมลไปยังหน้าถัดไป
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              NewPasswordScreen(email: widget.email), // ใช้ widget.email ที่นี่
        ),
      );
    } else {
      // แสดง Snackbar ถ้ามีข้อผิดพลาด
      EasyLoading.showError("OTP ไม่ถูกต้อง");
    }
  }

  List<Widget> getField() {
    final List<Widget> result = <Widget>[];
    for (int i = 1; i <= 6; i++) {
      result.add(SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFD9D9D9),
                ),
                height: 52,
                width: 52,
                child: Column(children: [
                  if (otp.length >= i)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 0),
                      child: Text(
                        otp[i - 1],
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ]),
              ),
            )
          ],
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลืมรหัสผ่าน"),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            SystemChannels.textInput.invokeMethod<String>('TextInput.hide');
          },
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 80),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: AppColor.appPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          15.0), // ค่านี้ควบคุมความกลมของมุม
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: AppColor.appPrimaryColor,
                      size: 100.0,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      const Text(
                        'ยืนยันรหัส OTP',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'กรุณากรอกรหัส OTP ที่ส่งไปในอีเมล ${widget.email}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    child: Stack(children: <Widget>[
                      Positioned(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: getField(),
                      )),
                      Opacity(
                        opacity: 0,
                        child: TextFormField(
                          controller: otpController,
                          focusNode: textNode,
                          keyboardType: TextInputType.number,
                          onChanged: onOtpInput,
                          maxLength: 6,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 180),
                  PurpleButton(
                    label: 'ยืนยัน',
                    onPressed: () {
                      if (otp.length == 6) {
                        handleVerify();
                      } else {
                        EasyLoading.showInfo("กรุณากรอกรหัส OTP 6 หลัก");
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ไม่ได้รับรหัส OTP?',
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
          )),
    );
  }
}
