import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/notification_model.dart';
import 'package:parkfinder_customer/models/parking_area_model.dart';
import 'package:parkfinder_customer/screens/notification/notification_detail.dart';
import 'package:parkfinder_customer/screens/reserve/review.dart';
import 'package:parkfinder_customer/screens/reward/claim_reward.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/services/profile_service.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/services/reward_service.dart';

class NotificationCard extends StatefulWidget {
  final Notifications notifications;

  const NotificationCard({
    super.key,
    required this.notifications,
  });
  @override
  NotificationCardState createState() => NotificationCardState();
}

class NotificationCardState extends State<NotificationCard> {
  final rewardservice = RewardService();
  final profileservice = ProfileService();
  final reserveService = ReserveService();
  final parkingAreaService = ParkingAreaService();

  List<ParkingArea> parkingAreaFavList = [];

  @override
  void initState() {
    super.initState();
    _loadParkingAreaFavorite();
  }

  void _loadParkingAreaFavorite() async {
    try {
      final parkingAreas = await parkingAreaService.getParkingAreaFavorite();
      if (!mounted) return;
      setState(() {
        parkingAreaFavList = parkingAreas;
      });
    } catch (err) {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
  }

  Widget iconNotification() {
    String title = widget.notifications.title;
    if (widget.notifications.callbackMethod != null) {
      String url = widget.notifications.callbackMethod![0]['call_back_url'];
      String action = widget.notifications.callbackMethod![0]['action'];
      if (url.startsWith("http://34.125.122.199/customer/reward_detail")) {
        return const Center(
          child: Icon(Icons.local_offer, color: Colors.white),
        );
      } else if (action == "Review") {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(90)),
            child: const Icon(Icons.star_rounded,
                size: 35, color: AppColor.appYellow),
          ),
        );
      } else if (title == "เวลาการจองของคุณกำลังจะหมด" || title == "การจองของคุณครบกำหนด") {
        return Center(
            child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(90)),
          child: const Icon(Icons.timer_outlined,
              size: 35, color: AppColor.appPrimaryColor),
        ));
      }
    } else if (title == "การจองของคุณได้รับการอนุมัติ") {
      return Center(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(90)),
        child: const Icon(Icons.check_circle,
            size: 35, color: AppColor.appStatusGreen),
      ));
    } else if (title == "การจองของคุณถูกปฏิเสธ") {
      return Center(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(90)),
        child: const Icon(Icons.cancel, size: 35, color: AppColor.appStatusRed),
      ));
    } else if (title == "ที่จอดที่คุณจองมาเกิดปัญหาบางอย่าง"){
      return Center(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(90)),
        child: const Icon(Icons.error, size: 35, color: AppColor.appStatusRed),
      ));
    }
    return const Center(
      child: Text(
        'P',
        style: TextStyle(
            color: Colors.white, fontSize: 35, fontWeight: FontWeight.w900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.notifications.callbackMethod != null) {
          String url = widget.notifications.callbackMethod![0]['call_back_url'];
          String action = widget.notifications.callbackMethod![0]['action'];
          if (url.startsWith("http://34.125.122.199/customer/reward_detail")) {
            EasyLoading.show();
            Uri uri = Uri.parse(url);
            String? rewardID = uri.queryParameters['_id'];

            final profile = await profileservice.getProfile();
            final response = await rewardservice.getRewardDetail(rewardID!);

            EasyLoading.dismiss();
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClaimRewardScreen(
                        rewardID: rewardID,
                        title: response!.title,
                        description: response.description,
                        expiredDate: response.expiredDate,
                        imageURL: response.previewImageUrl,
                        condition: response.condition,
                        point: response.point,
                        profilePoint: profile!.point)));
          } else if (action == "Review") {
            EasyLoading.show();
            final orderID = widget.notifications.description.split("|")[1];
            final parkingID = widget.notifications.description.split("|")[2];
            final checkReview = await reserveService.checkCanReview(orderID);
            final parkingAreaDetail =
                await parkingAreaService.getParkingAreaDetail(parkingID);
            bool isParkingFavSelect = false;
            if (parkingAreaService.isParkingAreaExist(
                parkingAreaFavList, parkingID)) {
              setState(() {
                isParkingFavSelect = true;
              });
            }
            EasyLoading.dismiss();
       
            if (checkReview is bool) {
              if (checkReview) {
                // ignore: use_build_context_synchronously
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReviewPage(
                              parkingAreaDetail: parkingAreaDetail!,
                              isReview: false,
                              orderID: orderID,
                              isParkingFavSelect: isParkingFavSelect,
                            )));
              } else {
                EasyLoading.showError("หมดเวลา Review");
              }
            } else if (checkReview is Map) {
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReviewPage(
                            parkingAreaDetail: parkingAreaDetail!,
                            isReview: true,
                            reviewScore: checkReview['review_score'],
                            comment: checkReview['comment'],
                            isParkingFavSelect: isParkingFavSelect,
                          )));
            } else {
              EasyLoading.showError("หมดเวลา Review");
            }
          } else if (widget.notifications.title == "เราไม่พบรถของคุณ") {
            final description = widget.notifications.description.split("|")[0];
            final parkingName = widget.notifications.description.split("|")[1];
            final startDate = widget.notifications.description.split("|")[2];
            final endDate = widget.notifications.description.split("|")[3];
            final hourStart = widget.notifications.description.split("|")[4];
            final hourEnd = widget.notifications.description.split("|")[5];
            final minStart = widget.notifications.description.split("|")[6];
            final minEnd = widget.notifications.description.split("|")[7];
            final price = widget.notifications.description.split("|")[8];
            final carUrl = widget.notifications.description.split("|")[9];
            final callBackConfirm =
                widget.notifications.callbackMethod![0]['call_back_url'];
            final callBackCancel =
                widget.notifications.callbackMethod![1]['call_back_url'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen(
                          appBar: "การแจ้งเตือน",
                          typeNotification: "carConfirm",
                          title: widget.notifications.title,
                          description: description,
                          parkingName: parkingName,
                          startDate: startDate,
                          endDate: endDate,
                          entryTime: TimeOfDay(
                              hour: int.parse(hourStart),
                              minute: int.parse(minStart)),
                          exitTime: TimeOfDay(
                              hour: int.parse(hourEnd),
                              minute: int.parse(minEnd)),
                          price: int.parse(price),
                          stringPrice: "",
                          callBackConfirm: callBackConfirm,
                          callBackCancel: callBackCancel,
                          carUrl: carUrl,
                        )));
          } else if (widget.notifications.title ==
              "เวลาการจองของคุณกำลังจะหมด" || widget.notifications.title == "การจองของคุณครบกำหนด") {  
            final description = widget.notifications.description.split("|")[0];
            final parkingName = widget.notifications.description.split("|")[1];
            final startDate = widget.notifications.description.split("|")[2];
            final endDate = widget.notifications.description.split("|")[3];
            final hourStart = widget.notifications.description.split("|")[4];
            final hourEnd = widget.notifications.description.split("|")[5];
            final minStart = widget.notifications.description.split("|")[6];
            final minEnd = widget.notifications.description.split("|")[7];
            final priceString = widget.notifications.description.split("|")[8];
            final carUrl = widget.notifications.description.split("|")[9];
            final callBackConfirm =
                widget.notifications.callbackMethod![0]['call_back_url'];
            final stringPrice = priceString.split("=")[0];
            final price = priceString.split("=")[1];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen(
                          appBar: "การแจ้งเตือน",
                          typeNotification: "extendTimeNoti",
                          title: widget.notifications.title,
                          description: description,
                          parkingName: parkingName,
                          startDate: startDate,
                          endDate: endDate,
                          entryTime: TimeOfDay(
                              hour: int.parse(hourStart),
                              minute: int.parse(minStart)),
                          exitTime: TimeOfDay(
                              hour: int.parse(hourEnd),
                              minute: int.parse(minEnd)),
                          stringPrice: stringPrice,
                          price: int.parse(price),
                          callBackConfirm: callBackConfirm,
                          carUrl: carUrl,
                        )));
          }
        } else if (widget.notifications.title ==
                "การจองของคุณได้รับการอนุมัติ" ||
            widget.notifications.title == "การจองของคุณถูกปฏิเสธ") {
          final description = widget.notifications.description.split("|")[0];
          final parkingName = widget.notifications.description.split("|")[1];
          final startDate = widget.notifications.description.split("|")[2];
          final endDate = widget.notifications.description.split("|")[3];
          final hourStart = widget.notifications.description.split("|")[4];
          final hourEnd = widget.notifications.description.split("|")[5];
          final minStart = widget.notifications.description.split("|")[6];
          final minEnd = widget.notifications.description.split("|")[7];
          final priceString = widget.notifications.description.split("|")[8];
          const carUrl = "";
          final stringPrice = priceString.split("=")[0];
          final price = priceString.split("=")[1];
          final type =
              widget.notifications.title == "การจองของคุณได้รับการอนุมัติ"
                  ? "approve"
                  : "denined";
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(
                        appBar: "การแจ้งเตือน",
                        typeNotification: type,
                        title: widget.notifications.title,
                        description: description,
                        parkingName: parkingName,
                        startDate: startDate,
                        endDate: endDate,
                        entryTime: TimeOfDay(
                            hour: int.parse(hourStart),
                            minute: int.parse(minStart)),
                        exitTime: TimeOfDay(
                            hour: int.parse(hourEnd),
                            minute: int.parse(minEnd)),
                        stringPrice: stringPrice,
                        price: int.parse(price),
                        carUrl: carUrl,
                      )));
        } else if (widget.notifications.title == "ที่จอดที่คุณจองมาเกิดปัญหาบางอย่าง"){
          final description = widget.notifications.description.split("|")[0];
          final parkingName = widget.notifications.description.split("|")[1];
          final startDate = widget.notifications.description.split("|")[2];
          final endDate = widget.notifications.description.split("|")[3];
          final hourStart = widget.notifications.description.split("|")[4];
          final hourEnd = widget.notifications.description.split("|")[5];
          final minStart = widget.notifications.description.split("|")[6];
          final minEnd = widget.notifications.description.split("|")[7];
          final priceString = widget.notifications.description.split("|")[8];
          const carUrl = "";
          final stringPrice = priceString.split("=")[0];
          final price = priceString.split("=")[1];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(
                    appBar: "การแจ้งเตือน",
                    typeNotification: "cancelReserve",
                    title: widget.notifications.title,
                    description: description,
                    parkingName: parkingName,
                    startDate: startDate,
                    endDate: endDate,
                    entryTime: TimeOfDay(
                        hour: int.parse(hourStart),
                        minute: int.parse(minStart)),
                    exitTime: TimeOfDay(
                        hour: int.parse(hourEnd),
                        minute: int.parse(minEnd)),
                    stringPrice: stringPrice,
                    price: int.parse(price),
                    carUrl: carUrl,
                  )));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: AppColor.appPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: iconNotification()),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // ทำให้ Column มีขนาดพอดีกับเนื้อหา
                children: [
                  Text(widget.notifications.title,
                      style: const TextStyle(fontSize: 17),
                      overflow: TextOverflow.ellipsis),
                  Text(
                    widget.notifications.description.split("|")[0],
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat("yyyy-MM-dd HH:mm:ss")
                        .format(widget.notifications.time),
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // if (widget.notifications.callbackMethod != null)
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
