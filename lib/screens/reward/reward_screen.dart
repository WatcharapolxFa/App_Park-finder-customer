import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/models/point_history_modal.dart';
import 'package:parkfinder_customer/models/profile_modal.dart';
import 'package:parkfinder_customer/screens/reward/claim_reward.dart';
import 'package:parkfinder_customer/screens/reward/reward_confirm.dart';
import 'package:parkfinder_customer/services/profile_service.dart';
import 'package:parkfinder_customer/widgets/reward_card.dart';
import '../../assets/colors/constant.dart';
import 'package:parkfinder_customer/models/reward_model.dart';
import 'package:parkfinder_customer/services/reward_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  RewardScreenState createState() => RewardScreenState();
}

class RewardScreenState extends State<RewardScreen> {
  final rewardService = RewardService();
  final profileService = ProfileService();
  late String selectedStatus;
  int index = 0;
  late List<RewardDetail> rewards = [];
  late List<MyRewardDetail> myRewards = [];
  late Profile? profile;
  int point = 0;
  bool _isLoadRewards = false;
  bool _isLoadPointHistory = false;
  late List<PointHistory> pointHistory = [];

  @override
  void initState() {
    super.initState();
    selectedStatus = 'คูปองทั้งหมด';
    loadProfile();
    loadRewards(0);
  }

  Future<void> loadRewards(int index) async {
    setState(() {
      _isLoadRewards = true;
    });
    if (index == 0){
      rewards = await rewardService.fetchRewards();
    }
    else if (index == 1) {
      myRewards = await rewardService.fetchMyRewards();
    }
    if (!mounted) return;
    setState(() {
      _isLoadRewards = false;
    });
  }

  Future<void> loadProfile() async {
    profile = await profileService.getProfile();
    point = profile!.point;
    if (!mounted) return;
    setState(() {});
  }

  Future loadPointHistory() async {
    setState(() {
      _isLoadPointHistory = true;
    });
    pointHistory = await rewardService.getHistoryPoint();
    if (!mounted) return;
    setState(() {
      _isLoadPointHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("คูปอง",
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          centerTitle: true,
          backgroundColor: AppColor.appPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusButton('คูปองทั้งหมด'),
                  _buildStatusButton('คูปองของฉัน'),
                  _buildStatusButton('ประวัติคะแนน'),
                ],
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Padding ซ้ายและขวา
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SvgPicture.asset(
                        'lib/assets/images/logoParkfinder.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            const Text("คุณมี ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(NumberFormat("#,##0", "en_US").format(point),
                                style: const TextStyle(
                                    color: AppColor.appPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const Text(" คะแนน",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16))
                          ],
                        )),
                  ],
                ),
              ),
              if (_isLoadRewards || _isLoadPointHistory)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CupertinoPopupSurface(
                    isSurfacePainted: false,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                ),
              if (index == 0)
                ...rewards.map(
                  (data) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClaimRewardScreen(
                                    rewardID: data.id,
                                    description: data.description,
                                    condition: data.condition,
                                    expiredDate: data.expiredDate,
                                    imageURL: data.previewImageUrl,
                                    point: data.point,
                                    profilePoint: point,
                                    title: data.title,
                                  )),
                        );
                      },
                      child: RewardCard(
                          title: data.title,
                          subtitle: data.description,
                          expiryDate: data.expiredDate,
                          imageUrl: data.previewImageUrl)),
                ),
                if (index == 1)
                ...myRewards.map(
                  (data) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RewardConfirmScreen(barcodeURL: data.barcodeUrl.toString().split("?")[0], rewardID: data.id, title: data.title, description: data.description, customerExpiredDate: data.customerExpiredDate, imageURL: data.previewUrl, condition: data.condition, point: data.point)),
                        );
                      },
                      child: RewardCard(
                          title: data.title,
                          subtitle: data.description,
                          customerExpiryDate: data.customerExpiredDate,
                          imageUrl: data.previewUrl)),
                ),
                
              const SizedBox(height: 15),
              if (index == 2)
                ...pointHistory.asMap().entries.map(
                      (entry) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            color: entry.key % 2 == 0
                                ? const Color(0xFFCDCDCD)
                                : Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.value.content,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      entry.value.timeStampString,
                                      style: const TextStyle(fontSize: 11),
                                    )
                                  ],
                                )),
                                Text(
                                  "${entry.value.type == "received" ? "+" : "-"} ${entry.value.point} คะแนน",
                                  style: TextStyle(
                                      color: entry.value.type == "received"
                                          ? const Color(0xFF10AF48)
                                          : const Color(0xFFDC2E40)),
                                )
                              ],
                            ),
                          )),
                    )
            ],
          ),
        ));
  }

  Widget _buildStatusButton(String status) {
    bool isSelected = selectedStatus == status;
    return TextButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
          if (status == "คูปองทั้งหมด") {
            index = 0;
            rewards = [];
            loadRewards(index);
          } else if (status == "คูปองของฉัน") {
            index = 1;
            rewards = [];
            loadRewards(index);
          } else if (status == "ประวัติคะแนน") {
            index = 2;
            pointHistory = [];
            loadPointHistory();
          }
        });
      },
      child: Text(
        status,
        style: TextStyle(
            color:
                isSelected ? AppColor.appPrimaryColor : const Color(0xFFB2B2B2),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 17),
      ),
    );
  }
}
