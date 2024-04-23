import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'dart:async';
import '../../assets/colors/constant.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage(
      {super.key, required this.email, required this.accessToken});
  final String email;
  final String accessToken;

  @override
  AuthenticationPageState createState() => AuthenticationPageState();
}

class AuthenticationPageState extends State<AuthenticationPage> {
  String otp = '';
  final otpController = TextEditingController();
  final textNode = FocusNode();
  final logger = Logger();
  final storage = const FlutterSecureStorage();
  bool _canResendOTP = true; // ตัวแปรติดตามสถานะปุ่ม
  Timer? _timer; // Timer สำหรับนับถอยหลัง

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

    final url = Uri.parse('${dotenv.env['HOST']}/customer/verify_otp');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        await storage.write(key: 'accessToken', value: widget.accessToken);
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

    final url = Uri.parse('${dotenv.env['HOST']}/customer/resend_login_otp');

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
    EasyLoading.show();
    final result = await registerCustomer();
    setState(() {
      otp = '';
      otpController.clear();
      textNode.unfocus();
    });
    EasyLoading.dismiss();
    if (result != null) {
      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/logged_in');
    } else {
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
        title: const Text("การยืนยันตัวตนสองขั้นตอน"),
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
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 200,
                ),
                const SizedBox(
                    height: 110,
                    child: Column(
                      children: [
                        Text(
                          'การยืนยันขั้นที่ 2',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'กรุณากรอกรหัส OTP ที่ส่งไปในอีเมล',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 400,
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
                const SizedBox(
                  height: 30,
                ),
                PurpleButton(
                  label: 'ยืนยัน',
                  onPressed: () => {
                    if (otp.length == 6)
                      {handleVerify()}
                    else
                      {EasyLoading.showInfo("กรุณากรอก OTP")}
                  },
                ),
                const SizedBox(
                  height: 150,
                ),
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
          )),
    );
  }
}
