import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/screens/reserve/status_pending.dart';
import 'package:parkfinder_customer/screens/reserve/status_succeed.dart';
import 'package:parkfinder_customer/screens/search/filter.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_color.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({
    super.key,
    required this.appBar,
    required this.typeNotification,
    this.parkingName,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.entryTime,
    this.exitTime,
    this.stringPrice,
    this.price,
    this.callBackConfirm,
    this.callBackCancel,
    this.carUrl,
    this.orderID,
  });
  final String appBar;
  final String typeNotification;
  final String? parkingName;
  final String? title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final TimeOfDay? entryTime;
  final TimeOfDay? exitTime;
  final String? stringPrice;
  final int? price;
  final String? callBackConfirm;
  final String? callBackCancel;
  final String? carUrl;
  final String? orderID;

  @override
  NotificationDetailState createState() => NotificationDetailState();
}

class NotificationDetailState extends State<NotificationDetailScreen> {
  final reserveService = ReserveService();
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  Future<void> getPosition() async {
    _currentPosition = await _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  String convertTypeNotificationButton1() {
    if (widget.typeNotification == "carConfirm") {
      return "ใช่ รถของฉันเอง";
    } else if (widget.typeNotification == "extendTimeNoti" ||
        widget.typeNotification == "extend") {
      return "ขยายระยะเวลาการจอด 1 ชั่วโมง";
    } else if (widget.typeNotification == "cancelReserve") {
      return "หาที่จอดรถใหม่";
    }
    return "";
  }

  String convertTypeNotificationButton2() {
    if (widget.typeNotification == "carConfirm") {
      return "ไม่ใช่รถของฉัน";
    } else if (widget.typeNotification == "extendTimeNoti" ||
        widget.typeNotification == "extend") {
      return "ออกตามเวลา";
    }
    return "";
  }

  Widget iconNotification() {
    if (widget.typeNotification == "approve") {
      return const Icon(
        Icons.check_circle,
        color: AppColor.appPrimaryColor,
        size: 100.0,
      );
    } else if (widget.typeNotification == "denined") {
      return const Icon(
        Icons.cancel,
        color: AppColor.appPrimaryColor,
        size: 100.0,
      );
    } else if (widget.typeNotification == "cancelReserve") {
      return const Icon(
        Icons.error_outline,
        color: AppColor.appPrimaryColor,
        size: 100.0,
      );
    } else {
      return const Icon(
        Icons.timer_outlined,
        color: AppColor.appPrimaryColor,
        size: 100.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appBar,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColor.appPrimaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(90.0), // ค่านี้ควบคุมความกลมของมุม
              ),
              child: iconNotification(),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Text(
                  widget.title!,
                  style: const TextStyle(
                      color: AppColor.appPrimaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Center(
              child: Visibility(
                  visible: widget.typeNotification == "extendTimeNoti" ||
                      widget.typeNotification == "extend" ||
                      widget.typeNotification == "approve" ||
                      widget.typeNotification == "denined" ||
                      widget.typeNotification == "cancelReserve",
                  child: Container(
                    margin: const EdgeInsets.all(35),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'lib/assets/images/logoParkfinder.svg',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.parkingName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('วันที่จอด'),
                            Text(widget.startDate!),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('วันที่ออก'),
                            Text(widget.endDate!),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('เวลาเข้าจอด'),
                            Text(
                                '${widget.entryTime!.hour.toString().padLeft(2, '0')}:${widget.entryTime!.minute.toString().padLeft(2, '0')} น.'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('เวลาออกจอด'),
                            Text(
                                '${widget.exitTime!.hour.toString().padLeft(2, '0')}:${widget.exitTime!.minute.toString().padLeft(2, '0')} น.'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.stringPrice!),
                            Text(
                              '${widget.price} บาท',
                              style:
                                  const TextStyle(color: AppColor.appGreenline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
            Visibility(
              visible: widget.typeNotification == "carConfirm",
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.network(
                    (widget.carUrl!),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: widget.typeNotification == "carConfirm",
                child: const SizedBox(height: 80)),
            Visibility(
              visible: widget.typeNotification == "carConfirm" ||
                  widget.typeNotification == "extendTimeNoti" ||
                  widget.typeNotification == "extend" ||
                  widget.typeNotification == "cancelReserve",
              child: PurpleButton(
                label: convertTypeNotificationButton1(),
                onPressed: () async {
                  EasyLoading.show();
                  if (widget.typeNotification == "carConfirm") {
                    final response = await reserveService
                        .confirmCar(widget.callBackConfirm!);
                    EasyLoading.dismiss();
                    if (response) {
                      EasyLoading.showInfo("ยืนยันรถสำเร็จ");
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/logged_in');
                    } else {
                      EasyLoading.showError("ยืนยันรถไม่สำเร็จ");
                    }
                  } else if (widget.typeNotification == "extendTimeNoti") {
                    final response = await reserveService
                        .extendReserveCallback(widget.callBackConfirm!);
                    if (response != false) {
                      final dataTransaction = response['data'];
                      final orderID = dataTransaction['order_id'];
                      final parkingID = dataTransaction['parking_id'];
                      final parkingName = dataTransaction['parking_name'];
                      final providerID = dataTransaction['provider_id'];
                      final quantity = dataTransaction['quantity'];
                      final price = dataTransaction['price'];
                      final cashback = dataTransaction['cashback'];
                      final responseTransaction =
                          await reserveService.createTransaction(
                              providerID,
                              orderID,
                              parkingID,
                              parkingName,
                              quantity.toDouble(),
                              price,
                              cashback);
                      if (responseTransaction['message'] ==
                          "Success payment with cashback") {
                        EasyLoading.dismiss();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StatusSucceedScreen(
                                      extend: true,
                                    )));
                      } else if (responseTransaction['message']
                          .toString()
                          .startsWith("https://web-pay.line.me")) {
                        await reserveService.cacheUrl(
                            responseTransaction['reservation_id'],
                            responseTransaction['message'],
                            DateTime.now().toString());
                        EasyLoading.dismiss();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StatusPendingScreen(
                                      reserveID:
                                          responseTransaction['reservation_id'],
                                    )));
                      }
                    } else {
                      EasyLoading.showError("ขยายเวลาไม่สำเร็จ");
                    }
                  } else if (widget.typeNotification == "extend") {
                    final response =
                        await reserveService.extendReserve(widget.orderID!);
                    if (response != false) {
                      final dataTransaction = response['data'];
                      final orderID = dataTransaction['order_id'];
                      final parkingID = dataTransaction['parking_id'];
                      final parkingName = dataTransaction['parking_name'];
                      final providerID = dataTransaction['provider_id'];
                      final quantity = dataTransaction['quantity'];
                      final price = dataTransaction['price'];
                      final cashback = dataTransaction['cashback'];
                      final responseTransaction =
                          await reserveService.createTransaction(
                              providerID,
                              orderID,
                              parkingID,
                              parkingName,
                              quantity.toDouble(),
                              price,
                              cashback);
                      if (responseTransaction['message'] ==
                          "Success payment with cashback") {
                        EasyLoading.dismiss();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StatusSucceedScreen(
                                      extend: true,
                                    )));
                      } else if (responseTransaction['message']
                          .toString()
                          .startsWith("https://web-pay.line.me")) {
                        await reserveService.cacheUrl(
                            responseTransaction['reservation_id'],
                            responseTransaction['message'],
                            DateTime.now().toString());
                        EasyLoading.dismiss();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StatusPendingScreen(
                                      reserveID:
                                          responseTransaction['reservation_id'],
                                    )));
                      }
                    } else {
                      EasyLoading.showError("ขยายเวลาไม่สำเร็จ");
                    }
                  } else if (widget.typeNotification == "cancelReserve") {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilterScreen(
                                currentPosition: _currentPosition,
                                isBookingNow: false)));
                  }
                  EasyLoading.dismiss();
                },
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: widget.typeNotification == "carConfirm" ||
                  widget.typeNotification == "extendTimeNoti" ||
                  widget.typeNotification == "extend",
              child: GaryButton(
                  label: convertTypeNotificationButton2(),
                  onPressed: () async {
                    EasyLoading.show();
                    if (widget.typeNotification == "carConfirm") {
                      final response = await reserveService
                          .confirmCar(widget.callBackCancel!);
                      EasyLoading.dismiss();
                      if (response) {
                        EasyLoading.showInfo(
                            "เราได้รับรู้ถึงปัญหาแล้ว\nจะติดต่อกลับไปโดยเร็ว");
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/logged_in');
                      } else {
                        EasyLoading.showError("ยืนยันรถไม่สำเร็จ");
                      }
                    } else if (widget.typeNotification == "extendTimeNoti") {
                      EasyLoading.dismiss();
                      EasyLoading.showInfo("ยืนยันออกตามเวลา");
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/logged_in');
                    } else if (widget.typeNotification == "extend") {
                      EasyLoading.dismiss();
                      EasyLoading.showInfo("ยืนยันออกตามเวลา");
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                    EasyLoading.dismiss();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
