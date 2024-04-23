import 'package:flutter/material.dart';
import 'package:parkfinder_customer/screens/car/car_list.dart';
import 'package:parkfinder_customer/screens/history/history.dart';
import 'package:parkfinder_customer/screens/home/home.dart';
import 'package:parkfinder_customer/screens/logged-in/index.dart';
import 'package:parkfinder_customer/screens/welcome/welcome.dart';
import 'package:parkfinder_customer/screens/login-register/login.dart';
import 'package:parkfinder_customer/screens/login-register/register.dart';
import 'package:parkfinder_customer/screens/login-register/reset_password.dart';
import 'package:parkfinder_customer/screens/welcome/welcome_1.dart';
import 'package:parkfinder_customer/screens/welcome/welcome_2.dart';
import 'package:parkfinder_customer/screens/myaddress/my_address.dart';
import 'package:parkfinder_customer/screens/reserve/status_succeed.dart';
import 'package:parkfinder_customer/screens/settings/setting.dart';
import 'package:parkfinder_customer/screens/reward/reward_screen.dart';
import 'package:parkfinder_customer/screens/notification/notification_list.dart';

class RouteConfig {
  static Map<String, WidgetBuilder> routes = {
    '/home': (context) => const HomePage(),
    '/welcome': (context) => const WelcomeScreen(),
    '/welcome1': (context) => const WelcomeScreenOne(),
    '/welcome2': (context) => const WelcomeScreenTwo(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/reset_password': (context) => const ResetPasswordScreen(),
    '/setting': (context) => const SettingPage(),
    '/my_address': (context) => const MyAddressPage(),
    '/history': (context) => const HistoryScreen(),
    '/car_list': (context) => const CarListPage(),
    '/logged_in': (context) => const LoggedInPage(
          screenIndex: 0,
        ),
    '/succeed': (context) => const StatusSucceedScreen(),
    '/reward': (context) => const RewardScreen(),
    '/notification': (context) => const NotificationListScreen(),
  };
}
