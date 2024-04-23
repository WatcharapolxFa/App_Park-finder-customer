import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/profile_modal.dart';
import 'package:parkfinder_customer/screens/chat/chat.dart';
import 'package:parkfinder_customer/screens/notification/notification_detail.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/services/profile_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/notic_dialog.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({
    super.key,
    required this.reserveID,
    required this.providerID,
    required this.providerName,
    required this.orderID,
    required this.parkingName,
    required this.dateStart,
    required this.dateEnd,
    required this.hourStart,
    required this.hourEnd,
    required this.minStart,
    required this.minEnd,
    required this.latitude,
    required this.longitude,
  });
  final String reserveID;
  final String providerID;
  final String providerName;
  final String orderID;
  final String parkingName;
  final String dateStart;
  final String dateEnd;
  final int hourStart;
  final int hourEnd;
  final int minStart;
  final int minEnd;
  final double latitude;
  final double longitude;
  @override
  MyLocationPageState createState() => MyLocationPageState();
}

class MyLocationPageState extends State<MyLocationPage> {
  final profileService = ProfileService();
  final reserveService = ReserveService();
  final parkgingAreaService = ParkingAreaService();
  late Profile? profile;
  bool _isLoadProfile = false;
  bool _isClickToChat = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    setState(() {
      _isLoadProfile = true;
    });
    profile = await profileService.getProfile();
    if (!mounted) return;
    setState(() {
      _isLoadProfile = false;
    });
    if (_isClickToChat) {
      EasyLoading.dismiss();
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                  reserveID: widget.reserveID,
                  senderID: profile!.profileID,
                  receiverID: widget.providerID)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.parkingName),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // ไอคอน X
          onPressed: () {
            Navigator.pop(context); // ย้อนกลับหน้า Home
            Navigator.pushNamed(context, "/logged_in");
          },
        ),
      ),
      body: SafeArea(
          bottom: false,
          child: Stack(fit: StackFit.expand, children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 18,
              ),
              // onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: MarkerId(widget.parkingName),
                  position: LatLng(
                      widget.latitude, widget.longitude), // Marker position
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              // onTap: (latlang) async {},
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 310,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 3))
                  ],
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  const Text("วันที่เริ่มการจอง"),
                                  Container(
                                    height: 30,
                                    width: 150,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          widget.dateStart,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  const Text("เวลาเข้าจอด"),
                                  Container(
                                    height: 30,
                                    width: 150,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                        const SizedBox(width: 15),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            "${widget.hourStart.toString().padLeft(2, '0')}:${widget.minStart.toString().padLeft(2, '0')}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  const Text("วันที่จบการจอง"),
                                  Container(
                                    height: 30,
                                    width: 150,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(widget.dateEnd)
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  const Text("เวลานำรถออก"),
                                  Container(
                                    height: 30,
                                    width: 150,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                        const SizedBox(width: 15),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            "${widget.hourEnd.toString().padLeft(2, '0')}:${widget.minEnd.toString().padLeft(2, '0')}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 10,
                            color: const Color(0xFF6828DC),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          const Text("ธุรกรรมด่วน")
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_isLoadProfile) {
                                    EasyLoading.show();
                                    setState(() {
                                      _isClickToChat = true;
                                    });
                                  } else {
                                    EasyLoading.dismiss();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                                reserveID: widget.reserveID,
                                                senderID: profile!.profileID,
                                                receiverID:
                                                    widget.providerID)));
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5,
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 3))
                                      ],
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6828DC)),
                                  child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text("แชท")
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  EasyLoading.show();
                                  final response = await reserveService
                                      .capturePicture(widget.orderID);

                                  if (response != null) {
                                    EasyLoading.dismiss();
                                    // ignore: use_build_context_synchronously
                                    CustomDialogWidget.show(
                                      context: context,
                                      imageUrl: response,
                                      onConfirm: () {
                                        // ทำอะไรสักอย่างเมื่อผู้ใช้กดยืนยัน
                                        Navigator.of(context)
                                            .pop(); // ตัวอย่าง: ปิดป็อบอัพ
                                      },
                                      onCancel: () {
                                        // ทำอะไรสักอย่างเมื่อผู้ใช้กดยกเลิก
                                        Navigator.of(context)
                                            .pop(); // ตัวอย่าง: ปิดป็อบอัพ
                                      },
                                    );
                                  }
                                  EasyLoading.dismiss();
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5,
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 3))
                                      ],
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6828DC)),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text("ขอรูป")
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  // final parking = await parkgingAreaService.getParkingAreaDetail(widget.p)
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationDetailScreen(
                                                appBar: "ขยายเวลา",
                                                title: "การขยายเวลาจอด",
                                                description:
                                                    "คุณต้องการที่จะขยายเวลา เพิ่ม 1 ชั่วโมงหรือไม่?",
                                                typeNotification: "extend",
                                                parkingName: widget.parkingName,
                                                startDate: widget.dateStart,
                                                endDate: widget.dateEnd,
                                                entryTime: TimeOfDay(
                                                    hour: widget.hourStart,
                                                    minute: widget.minStart),
                                                exitTime: TimeOfDay(
                                                    hour: widget.hourEnd,
                                                    minute: widget.minEnd),
                                                carUrl: "",
                                                stringPrice: "ราคารวม",
                                                price: 2,
                                                orderID: widget.orderID,
                                              )));
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5,
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 3))
                                      ],
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6828DC)),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text("ขยายเวลา")
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                ),
              ),
            )
          ])),
    );
  }
}
