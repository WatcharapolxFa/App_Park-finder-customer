import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';

class WelcomeScreenTwo extends StatelessWidget {
  const WelcomeScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'ยินดีต้อนรับสู่',
                    style: TextStyle(
                      color: Color(0xFF5E5E5E),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SvgPicture.asset(
                    'lib/assets/images/logoParkfinder.svg',
                    width: 200,
                    height: 40,
                  ),
                  const SizedBox(height: 50),
                  Image.asset(
                    'lib/assets/images/welcome03.png',
                    width: 410,
                    height: 410,
                  ),
                  const SizedBox(height: 30),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'มาเริ่มต้นสัมผัสประสบการณ์ที่ใกล้ชิดกับที่จอดรถที่ ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'คุณต้องการ ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  PurpleButton(
                    label: 'เริ่มต้น',
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
