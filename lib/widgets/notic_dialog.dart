import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDialogWidget extends StatelessWidget {
  // final String message;
  final String imageUrl;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomDialogWidget({
    super.key,
    // required this.message,
    required this.imageUrl,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            'lib/assets/images/logoParkfinder.svg',
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 20),
          Image.network(imageUrl),
          // const SizedBox(height: 20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: <Widget>[
          //     TextButton(
          //       onPressed: onCancel, // ปิด Dialog
          //       child: const Text(
          //         "ยกเลิก",
          //         style: TextStyle(color: Colors.red),
          //       ),
          //     ),
          //     TextButton(
          //       onPressed: onConfirm, // ปฏิบัติการเมื่อกดยืนยัน
          //       child: const Text(
          //         "ยืนยัน",
          //         style: TextStyle(color: Colors.green),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String imageUrl,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialogWidget(
        imageUrl: imageUrl,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
