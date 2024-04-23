import 'package:flutter/material.dart';
import 'package:parkfinder_customer/screens/car/car_list.dart';
import 'package:parkfinder_customer/screens/history/history.dart';
import 'package:parkfinder_customer/screens/home/home.dart';
import 'package:parkfinder_customer/screens/notification/notification_list.dart';
import 'package:parkfinder_customer/screens/settings/setting.dart';
import 'package:parkfinder_customer/widgets/navbar/navbar.dart';

class LoggedInPage extends StatefulWidget {
  const LoggedInPage({super.key, required this.screenIndex});
  final int screenIndex;

  @override
  LoggedInState createState() => LoggedInState();
}

class LoggedInState extends State<LoggedInPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // ignore: unrelated_type_equality_checks
    _selectedIndex = widget.screenIndex != Null ? widget.screenIndex : 0;
  }

  final _pages = [
    const HomePage(),
    const CarListPage(),
    const HistoryScreen(),
    const NotificationListScreen(),
    const SettingPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }
}
