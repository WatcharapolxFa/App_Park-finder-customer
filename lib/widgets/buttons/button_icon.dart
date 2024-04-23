import 'package:flutter/material.dart';


class ButtonIcon extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData icon; // ไอคอนที่ต้องการแสดง

  // ทำให้พารามิเตอร์สีและไอคอนเป็น optional และกำหนดค่า default หากไม่ได้รับค่าใดๆ
  const ButtonIcon({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    required this.icon, // ทำให้ไอคอนเป็นพารามิเตอร์ที่จำเป็นต้องมี
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 309, // กำหนดความกว้าง
      height: 54, // กำหนดความสูง
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white, // กำหนดสีของไอคอน
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(color), // ใช้พารามิเตอร์สีที่รับเข้ามา
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(const EdgeInsets.all(
              15)), // ปรับ padding เพื่อให้เข้ากับความสูงใหม่
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // ปรับเป็น borderRadius 10px
            ),
          ),
        ),
      ),
    );
  }
}
