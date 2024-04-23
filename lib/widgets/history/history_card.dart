import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/history_model.dart';

class HistoryCard extends StatelessWidget {
  final History history;
  final bool showPrice; // เพิ่มการตั้งค่าเพื่อความยืดหยุ่นในการแสดงราคา
  final bool showStatus; // ตัวเลือกในการแสดงหรือซ่อนสถานะ
  final Color? customColor; // สามารถปรับสีของ card ได้

  const HistoryCard(
      {super.key,
      required this.history,
      this.showPrice = true, // ตั้งค่าเริ่มต้นให้แสดงราคา
      this.showStatus = true, // ตั้งค่าเริ่มต้นให้แสดงสถานะ
      this.customColor // ไม่มีค่าเริ่มต้น เพื่อให้สามารถกำหนดได้ตามต้องการ
      });
  Widget historyStatusToText(String status) {
    String text;
    Color color;
    switch (status) {
      case "Cancel":
        text = "การจองถูกยกเลิก";
        color = AppColor.appStatusRed;
        break;
      case "Successful":
        text = "ทำการจอดเรียบร้อย";
        color = AppColor.appStatusGreen;
        break;
      case "Pending":
        text = "รอการชำระเงิน";
        color = AppColor.appYellow;
        break;
      case "Pending Approval":
        text = "รอการชำระเงิน";
        color = AppColor.appYellow;
        break;
      case "Pending Approval Process":
        text = "รอการอนุมัติ";
        color = AppColor.appStatusRed;
        break;
      case "Process":
        text = "จ่ายเงินสำเร็จ";
        color = AppColor.appPrimaryColor;
        break;
      case "Parking":
        text = "กำลังจอด";
        color = AppColor.appStatusGreen;
        break;

      default:
        text = "รอการดำเนินการ";
        color = AppColor.appPrimaryColor;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  String convertToTwoDigitFormat(String input) {
    return input.length == 1 ? "0$input" : input;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColor.appPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(history.dateStart),
                        if (history.dateStart != history.dateEnd)
                          const Text(" - "),
                        if (history.dateStart != history.dateEnd)
                          Text(history.dateEnd),
                        const SizedBox(width: 10),
                        Text(convertToTwoDigitFormat(
                            (history.hourStart).toString())),
                        const Text(":"),
                        Text(convertToTwoDigitFormat(
                            (history.minStart).toString())),
                        const Text(" - "),
                        Text(convertToTwoDigitFormat(
                            (history.hourEnd).toString())),
                        const Text(":"),
                        Text(convertToTwoDigitFormat(
                            (history.minEnd).toString())),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 16),
                        Text(
                          " ${history.parkingName}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF6828DC), size: 16),
                        Expanded(
                          child: Text(
                            history.address,
                            style: const TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    historyStatusToText(history.status)
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '฿${history.price}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          ),
          const Divider(thickness: 1)
        ],
      ),
    );
  }
}
