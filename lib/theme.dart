import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // กำหนดค่าต่างๆ สำหรับ light theme ได้ที่นี่
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.appPrimaryColor, // กำหนด seed color
      ),
      fontFamily: 'Sukhumvit', // กำหนด font family
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.appPrimaryColor,
        foregroundColor: Colors.white, // สีของตัวหนังสือและไอคอน
        iconTheme: IconThemeData(color: Colors.white), // สีของไอคอน
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // กำหนดค่าอื่นๆ ตามที่ต้องการ
    );
  }
}
