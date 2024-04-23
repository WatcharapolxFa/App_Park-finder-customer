import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';

class WelcomeScreenOne extends StatelessWidget {
  const WelcomeScreenOne({super.key});

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
                  const SizedBox(height: 140),
                  Image.asset(
                    'lib/assets/images/welcome02.png',
                    width: 265,
                    height: 265,
                  ),
                  const SizedBox(height: 85),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'สามารถดูข้อมูลการจองได้ทันที',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  PurpleButton(
                    label: 'ต่อไป',
                    onPressed: () {
                      Navigator.pushNamed(context, '/welcome2');
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
