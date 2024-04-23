import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

class CustomNavBarState extends State<CustomNavBar> {
  Color defaultColor = Colors.black87;
  Color activeColor = AppColor.appPrimaryColor;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
        widget.onTap(index);
      });
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: widget.currentIndex != 0
                    ? Colors.transparent
                    : AppColor.appPrimaryAlphaColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Icon(Icons.home,
                  color: widget.currentIndex == 0 ? activeColor : defaultColor),
            ),
          ),
          label: 'หน้าแรก',
        ),
        BottomNavigationBarItem(
          icon: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: widget.currentIndex != 1
                    ? Colors.transparent
                    : AppColor.appPrimaryAlphaColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Icon(Icons.directions_car,
                  color: widget.currentIndex == 1 ? activeColor : defaultColor),
            ),
          ),
          label: 'รถของฉัน',
        ),
        BottomNavigationBarItem(
          icon: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: widget.currentIndex != 2
                    ? Colors.transparent
                    : AppColor.appPrimaryAlphaColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.inbox,
                          color: widget.currentIndex == 2
                              ? activeColor
                              : defaultColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          label: 'การจอง',
        ),
        BottomNavigationBarItem(
          icon: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: widget.currentIndex != 3
                    ? Colors.transparent
                    : AppColor.appPrimaryAlphaColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Icon(Icons.notifications,
                  color: widget.currentIndex == 3 ? activeColor : defaultColor),
            ),
          ),
          label: 'การแจ้้งเตือน',
        ),
        BottomNavigationBarItem(
          icon: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: widget.currentIndex != 4
                    ? Colors.transparent
                    : AppColor.appPrimaryAlphaColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Icon(Icons.account_circle,
                  color: widget.currentIndex == 4 ? activeColor : defaultColor),
            ),
          ),
          label: 'โปรไฟล์',
        ),
      ],
      backgroundColor: Colors.white, // กำหนดพื้นหลัง navbar เป็นสีขาว
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      selectedItemColor: activeColor,
      unselectedItemColor: defaultColor,
      showUnselectedLabels: true,
    );
  }
}
