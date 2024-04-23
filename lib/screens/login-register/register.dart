import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkfinder_customer/screens/login-register/verifly_email.dart';
import 'package:parkfinder_customer/widgets/buttons/text_field.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../assets/colors/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final logger = Logger();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<String?> registerCustomer(Map<String, dynamic> data) async {
    final url = Uri.parse('${dotenv.env['HOST']}/customer/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return response.body; // สำเร็จ คืนข้อมูลจาก response
      } else {
        return null; // ไม่สำเร็จ
      }
    } catch (error) {
      logger.i('Error connecting to API: $error');
      return null;
    }
  }

  Future<void> _handleRegistration() async {
    final data = {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'password': passwordController.text,
    };

    final result = await registerCustomer(data);

    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerifyEmailPage(email: emailController.text),
            ),
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
              content: Text('การลงทะเบียนไม่สำเร็จ, โปรดลองใหม่อีกครั้ง.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Logo
                      SvgPicture.asset(
                        'lib/assets/images/logoParkfinder.svg',
                        width: 50,
                        height: 50,
                      ),

                      const SizedBox(height: 40),

                      // Text "ลงทะเบียน"
                      const Text(
                        'ลงทะเบียน',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 60),

                      CustomTextField(
                        controller: firstNameController,
                        label: 'ชื่อ',
                        iconData: Icons.person,
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: lastNameController,
                        label: 'นามสกุล',
                        iconData: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: phoneController,
                        label: 'เบอร์โทร',
                        iconData: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Only allow numbers
                          LengthLimitingTextInputFormatter(
                              10), // Limit to 10 characters
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ตรวจสอบอีเมล
                      CustomTextField(
                        controller: emailController,
                        label: 'อีเมล',
                        iconData: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'โปรดระบุอีเมลที่ถูกต้อง';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        label: 'รหัสผ่าน',
                        iconData: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: confirmPasswordController,
                        label: 'ยืนยันรหัสผ่าน',
                        iconData: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'รหัสผ่านไม่ตรงกัน';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // Registration Button (you can add functionality later)
                      PurpleButton(
                        label: 'ลงทะเบียน',
                        onPressed: () {
                          if (emailController.text.isNotEmpty &&
                              emailController.text.contains("@") &&
                              passwordController.text.isNotEmpty &&
                              confirmPasswordController.text.isNotEmpty &&
                              passwordController.text ==
                                  confirmPasswordController.text) {
                            _handleRegistration();
                          } else if (firstNameController.text.isEmpty) {
                            EasyLoading.showError("โปรดกรอกชื่อ");
                          } else if (lastNameController.text.isEmpty) {
                            EasyLoading.showError("โปรดกรอกนามสกุล");
                          } else if (phoneController.text.isEmpty) {
                            EasyLoading.showError("โปรดกรอกเบอร์โทร");
                          } else if (emailController.text.isEmpty) {
                            EasyLoading.showError("โปรดกรอกอีเมล");
                          } else if (passwordController.text.isEmpty) {
                            EasyLoading.showError("โปรดกรอกรหัสผ่าน");
                          } else if (confirmPasswordController.text.isEmpty) {
                            EasyLoading.showError("โปรดยืนยันรหัสผ่าน");
                          } else if (passwordController.text !=
                              confirmPasswordController.text) {
                            EasyLoading.showError(
                                "รหัสผ่านกับยืนยันรหัสผ่านไม่ตรงกัน");
                          } else {
                            EasyLoading.showError(
                                "ข้อมูลไม่ถูกต้อง โปรดตรวจสอบและกรอกใหม่");
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'เป็นสมาชิกอยู่แล้ว?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                color: AppColor.appPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
