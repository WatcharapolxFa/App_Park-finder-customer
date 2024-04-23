import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/parking_area_model.dart';
import 'package:parkfinder_customer/screens/logged-in/index.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
    required this.parkingAreaDetail,
    required this.isReview,
    this.reviewScore,
    this.comment,
    this.orderID,
    required this.isParkingFavSelect,
  });
  final ParkingArea parkingAreaDetail;
  final bool isReview;
  final int? reviewScore;
  final String? comment;
  final String? orderID;
  final bool isParkingFavSelect;
  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  final reserveService = ReserveService();
  final parkingAreaService = ParkingAreaService();
  bool isHeartSelected = false; // สถานะการเลือกปุ่มหัวใจ
  int selectedStars = 0;
  double averageReview = 0.0;
  final reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initReview();
    averageReview = parkingAreaService
        .calculateAverageReviewScore(widget.parkingAreaDetail.review);
    isHeartSelected = widget.isParkingFavSelect;
  }

  void initReview() {
    if (widget.isReview) {
      selectedStars = widget.reviewScore!;
      reviewController.text = widget.comment!;
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        if (!widget.isReview) {
          setState(() {
            selectedStars = index + 1;
          });
        }
      },
      icon: Icon(
        Icons.star,
        color: (index < selectedStars) ? AppColor.appYellow : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("รีวิวที่จอด"),
          centerTitle: true,
          backgroundColor: AppColor.appPrimaryColor,
          leading: IconButton(
              icon: const Icon(Icons.close), // ไอคอน X
              onPressed: () {
                Navigator.pop(context); // ย้อนกลับหน้า Home
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoggedInPage(screenIndex: 3)));
              }),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7.5),
                      child: Container(
                        width: 430,
                        height: 150,
                        color: Colors.grey[200], // พื้นหลังช่องใส่รูป
                        child: PageView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Image.network(
                              (widget.parkingAreaDetail.parkingPictureURL),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: InkWell(
                          onTap: () async {
                            EasyLoading.show();
                            if (isHeartSelected) {
                              await parkingAreaService.pushPullFavoriteParking(
                                  widget.parkingAreaDetail.parkingID, "pull");
                              EasyLoading.dismiss();
                              EasyLoading.showSuccess("นำที่จอดรถออกเรียบร้อย");
                            } else {
                              await parkingAreaService.pushPullFavoriteParking(
                                  widget.parkingAreaDetail.parkingID, "push");
                              EasyLoading.dismiss();

                              EasyLoading.showSuccess(
                                  "เพิ่มที่จอดรถโปรดเรียบร้อย");
                            }

                            setState(() {
                              isHeartSelected = !isHeartSelected;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(90)),
                            child: Icon(
                              isHeartSelected
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isHeartSelected ? Colors.red : Colors.black,
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ข้อความ
                    Text(
                      widget.parkingAreaDetail.parkingName,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${widget.parkingAreaDetail.address['address_text']} ${widget.parkingAreaDetail.address['sub_district']} ${widget.parkingAreaDetail.address['district']} ${widget.parkingAreaDetail.address['province']} ${widget.parkingAreaDetail.address['postal_code']}',
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColor.appYellow), // ไอคอนรูปดาวสีเหลือง
                    const SizedBox(width: 5.0), // ระยะห่างระหว่างดาวกับตัวเลข
                    Text(averageReview.toString(),
                        style: const TextStyle(fontSize: 14.0)), // คะแนน
                    const SizedBox(
                        width: 20.0), // ระยะห่างระหว่างคะแนนกับข้อความ
                    Text('${widget.parkingAreaDetail.review.length} รีวิว',
                        style: const TextStyle(fontSize: 14.0)), // จำนวนรีวิว
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2.0),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // ให้ดาวอยู่ตรงกลาง
                      children: List.generate(
                        5,
                        (index) => Row(
                          // ใช้ Row เพื่อควบคุมระยะห่างระหว่างดาว
                          children: [
                            if (index != 0)
                              const SizedBox(
                                  width:
                                      8.0), // ให้ระยะห่างระหว่างดาว 8 px ยกเว้นดาวตัวแรก
                            buildStar(index)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 335.0,
                  height: 200.0,
                  child: TextField(
                    controller: reviewController,
                    readOnly: widget.isReview,
                    maxLines:
                        null, // ให้ข้อความเด้งบรรทัดใหม่เมื่อพิมพ์เต็มกล่องข้อความ
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(), // สร้างขอบรอบ `TextField`
                      hintText:
                          'ข้อความ', // แสดงข้อความ "ข้อความ" เมื่อไม่มีข้อความอื่นใน `TextField`
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Visibility(
                    visible: !widget.isReview,
                    child: PurpleButton(
                      label: "ส่งความคิดเห็น",
                      onPressed: () async {
                        EasyLoading.show();
                        final response = await reserveService.reviewParkingArea(
                            widget.parkingAreaDetail.parkingID,
                            selectedStars,
                            reviewController.text,
                            widget.orderID!);
                        EasyLoading.dismiss();
                        if (response) {
                          EasyLoading.showSuccess("Review สำเร็จ");
                        } else {
                          EasyLoading.showError("ไม่สามารถ Review ได้");
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.popUntil(context, (route) => route.isFirst);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/logged_in');
                      },
                    )),
              ],
            ),
          ),
        ));
  }
}
