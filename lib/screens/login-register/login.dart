import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkfinder_customer/screens/login-register/authentication.dart';
import 'package:parkfinder_customer/widgets/buttons/text_field.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../assets/colors/constant.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );
  String? accessToken;

  String? emailValidator(String? value) {
    Pattern pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value!)) {
      return 'กรุณาป้อนอีเมลที่ถูกต้อง';
    } else {
      return null;
    }
  }

  // sign user in method
  Future<bool> signInWithAPI(String email, String password) async {
    Map data = {'Email': email, 'Password': password};
    String body = json.encode(data);

    final url = Uri.parse('${dotenv.env['HOST']}/customer/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _logger.d(data);
      accessToken = data['access_token'];
      return true;
    } else {
      _logger.e('Failed to connect to API: ${response.body}');
      return false;
    }
  }

  bool? signInSuccess;

  Future<void> handleSignIn() async {
    EasyLoading.show();
    bool success =
        await signInWithAPI(emailController.text, passwordController.text);
    setState(() {
      signInSuccess = success;
    });
  }

  void proceedAfterSignIn(BuildContext context, bool success) {
    EasyLoading.dismiss();
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationPage(
            email: emailController.text,
            accessToken: accessToken!,
          ),
        ),
      );
    } else {
      EasyLoading.showError("เข้าสู่ระบบล้มเหลว");
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (signInSuccess != null) {
        proceedAfterSignIn(context, signInSuccess!);
        signInSuccess = null; // reset the state after handling
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // logo
                SvgPicture.asset(
                  'lib/assets/images/logoParkfinder.svg',
                  width: 50,
                  height: 50,
                ),

                const SizedBox(height: 50),

                // welcome
                const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                CustomTextField(
                  controller: emailController,
                  label: 'อีเมล',
                  iconData: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: passwordController,
                  label: 'รหัสผ่าน',
                  iconData: Icons.lock,
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                // forgot password?
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/reset_password');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ลืมรหัสผ่าน',
                          style: TextStyle(color: AppColor.appPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                PurpleButton(
                  label: 'เข้าสู่ระบบ',
                  onPressed: () => {
                    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
                      if(emailController.text.contains("@")){
                        handleSignIn()
                      }
                      else {
                        EasyLoading.showError("กรุณากรอก Email ที่ถูกต้อง")
                      }
                    }
                    else {
                      EasyLoading.showInfo("กรุณากรอก Email และ Password")
                    }
                  },
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ยังไม่เป็นสมาชิก ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'ลงทะเบียน',
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
          )),
        ),
      ),
    );
  }
}
