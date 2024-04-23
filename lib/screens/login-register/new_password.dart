import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/screens/login-register/login.dart';
import 'package:parkfinder_customer/widgets/buttons/text_field.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../assets/colors/constant.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen({super.key, required this.email});

  @override
  NewPasswordState createState() => NewPasswordState();
}

class NewPasswordState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> updatePassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      EasyLoading.showError("รหัสผ่านไม่ตรงกัน");
      return;
    }

    final response = await http.patch(
      Uri.parse('${dotenv.env['HOST']}/customer/new_password'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': widget.email,
        'password': passwordController.text,
      }),
    );
    if (!mounted) return;

    if (response.statusCode == 200) {
      EasyLoading.showInfo("รหัสผ่านได้ถูกเปลี่ยนแล้ว");
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
      // Navigate back or to another screen if necessary
    } else {
      EasyLoading.showError("ไม่สามารถเปลี่ยนรหัสผ่านได้");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เปลี่ยนรหัสผ่าน"),
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
              const SizedBox(height: 30),
              const Column(
                children: [
                   Text(
                    'เปลี่ยนรหัสผ่าน',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                   SizedBox(height: 20),
                  Text(
                    'โปรดกรอกรหัสกรอกรหัสผ่านใหม่',
                    style:  TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Icon, Text and TextFields as before
              CustomTextField(
                controller: passwordController,
                label: 'รหัสผ่านใหม่',
                iconData: Icons.lock,
                keyboardType: TextInputType.text,
                obscureText: true, // Hide password
              ),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'ยืนยันรหัสผ่านใหม่',
                iconData: Icons.lock_outline,
                keyboardType: TextInputType.text,
                obscureText: true, // Hide password
              ),
              const SizedBox(height: 220),
              PurpleButton(
                label: 'ยืนยัน',
                onPressed: () => {
                  if (passwordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty)
                    {updatePassword()}
                  else
                    {
                      EasyLoading.showInfo(
                          "กรุณากรอก Password และ Confirm Password")
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
