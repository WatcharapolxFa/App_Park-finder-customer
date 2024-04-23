import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/widgets/buttons/text_field.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parkfinder_customer/screens/login-register/authentication_reset_password.dart';

import '../../assets/colors/constant.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();

  Future<bool> forgotPasswordWithAPI(String email) async {
    Map data = {'Email': email};
    String body = json.encode(data);
    final url = Uri.parse('${dotenv.env['HOST']}/customer/send_forgot_otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return response.statusCode == 200;
  }

  bool? emailsMatch;

  Future<void> handleEmail() async {
    bool match = await forgotPasswordWithAPI(emailController.text);
    // เช็คว่า context ยังมีอยู่หรือไม่ก่อนทำการใช้งาน
    if (!mounted) return;

    if (match) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              AuthenticationResetPasswordScreen(email: emailController.text),
        ),
      );
    } else {
      EasyLoading.showError("ไม่พบอีเมลนี้");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลืมรหัสผ่าน "),
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColor.appPrimaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(15.0), // ค่านี้ควบคุมความกลมของมุม
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: AppColor.appPrimaryColor,
                  size: 100.0,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                "ลืมรหัสผ่าน ?",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 27),
              const Text(
                "โปรดป้อนอีเมลของคุณ, รหัส OTP จะถูก\nส่งไปในอีเมลของคุณ เพื่อเปลี่ยนรหัสผ่านใหม่",
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 68),
              CustomTextField(
                controller: emailController,
                label: 'อีเมล',
                iconData: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 166),
              PurpleButton(
                label: 'ยืนยัน',
                onPressed: () {
                  if (emailController.text.isNotEmpty) {
                    if (emailController.text.contains("@")) {
                      handleEmail();
                    } else {
                      EasyLoading.showError("กรุณากรอก Email ที่ถูกต้อง");
                    }
                  } else {
                    EasyLoading.showInfo("กรุณากรอก Email");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
