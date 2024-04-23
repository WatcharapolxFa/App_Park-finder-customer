import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/reserve_model.dart';
import 'package:parkfinder_customer/screens/reserve/my_location.dart';
import 'package:parkfinder_customer/screens/reserve/scan_qr.dart';
import 'package:parkfinder_customer/models/history_model.dart';
import 'package:parkfinder_customer/screens/reserve/status_pending.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';

class HistoryCardHome extends StatefulWidget {
  const HistoryCardHome({super.key, required this.history});
  final History history;

  @override
  HistoryCardHomeState createState() => HistoryCardHomeState();
}

class HistoryCardHomeState extends State<HistoryCardHome> {
  final reserveService = ReserveService();
  late Reserve? reserveDetail;
  bool _isLoadReserve = false;
  bool _isClickToMyLocation = false;
  @override
  void initState() {
    super.initState();
    loadReserveDetail();
  }

  void loadReserveDetail() async {
    setState(() {
      _isLoadReserve = true;
    });
    reserveDetail =
        await reserveService.getReserveDetailwithID(widget.history.historyID);
    if (!mounted) return;
    setState(() {
      _isLoadReserve = false;
    });
    if (_isClickToMyLocation) {
      EasyLoading.dismiss();
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyLocationPage(
              reserveID: reserveDetail!.reserveID,
              providerID: reserveDetail!.providerID,
              providerName: reserveDetail!.providerName,
              orderID: reserveDetail!.orderID,
              parkingName: reserveDetail!.parkingName,
              dateStart: reserveDetail!.dateStart,
              dateEnd: reserveDetail!.dateEnd,
              hourStart: reserveDetail!.hourStart,
              hourEnd: reserveDetail!.hourEnd,
              minStart: reserveDetail!.minStart,
              minEnd: reserveDetail!.minEnd,
              latitude: reserveDetail!.latitude,
              longitude: reserveDetail!.longitude),
        ),
      );
    }
  }

  Widget historyStatusToText(String historyStatus) {
    String text = "";
    Color color;
    switch (historyStatus) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  String convertToTwoDigitFormat(String input) {
    return input.length == 1 ? "0$input" : input;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.history.status == "Parking") {
          if (_isLoadReserve) {
            EasyLoading.show();
            setState(() {
              _isClickToMyLocation = true;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyLocationPage(
                    reserveID: reserveDetail!.reserveID,
                    providerID: reserveDetail!.providerID,
                    providerName: reserveDetail!.providerName,
                    orderID: reserveDetail!.orderID,
                    parkingName: reserveDetail!.parkingName,
                    dateStart: reserveDetail!.dateStart,
                    dateEnd: reserveDetail!.dateEnd,
                    hourStart: reserveDetail!.hourStart,
                    hourEnd: reserveDetail!.hourEnd,
                    minStart: reserveDetail!.minStart,
                    minEnd: reserveDetail!.minEnd,
                    latitude: reserveDetail!.latitude,
                    longitude: reserveDetail!.longitude),
              ),
            );
          }
        } else if (widget.history.status == "Process") {
          DateTime fiveMinBefore = reserveService
              .convertStringtoDateTimewithTimeInt(widget.history.dateStart,
                  widget.history.hourStart, widget.history.minStart)
              .subtract(const Duration(minutes: 5));

          bool isBeforeReserveTimeFiveMin =
              DateTime.now().isBefore(fiveMinBefore);

          if (!isBeforeReserveTimeFiveMin) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScanQrPage(
                          reserveID: widget.history.historyID,
                        )));
          } else {
            EasyLoading.showInfo(
                "สามารถแสกน QR ได้เวลา ${DateFormat('yyyy-MM-dd HH:mm').format(fiveMinBefore)}");
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StatusPendingScreen(
                      reserveID: widget.history.historyID)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white, // สีพื้นหลัง
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                historyStatusToText(widget.history.status),
                Text(widget.history.parkingName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))
              ],
            ),
            const Divider(color: Colors.grey), // เส้นแบ่งสีเทา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("เวลาในการจอง",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                Row(
                  children: [
                    Text(widget.history.dateStart),
                    if (widget.history.dateStart != widget.history.dateEnd)
                      const Text(" - "),
                    if (widget.history.dateStart != widget.history.dateEnd)
                      Text(widget.history.dateEnd),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(convertToTwoDigitFormat(
                        (widget.history.hourStart).toString())),
                    const Text(":"),
                    Text(convertToTwoDigitFormat(
                        (widget.history.minStart).toString())),
                    const Text(" - "),
                    Text(convertToTwoDigitFormat(
                        (widget.history.hourEnd).toString())),
                    const Text(":"),
                    Text(convertToTwoDigitFormat(
                        (widget.history.minEnd).toString())),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
