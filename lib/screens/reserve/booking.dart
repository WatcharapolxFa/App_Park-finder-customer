import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/models/profile_modal.dart';
import 'package:parkfinder_customer/screens/reserve/sumary.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/services/profile_service.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BookingPage extends StatefulWidget {
  const BookingPage(
      {super.key,
      required this.parkingID,
      required this.providerID,
      required this.parkingName,
      required this.parkingUrl,
      required this.address,
      required this.price,
      required this.review,
      required this.startDate,
      required this.endDate,
      required this.entryTime,
      required this.exitTime,
      required this.isParkingFavSelect});
  final String parkingID;
  final String providerID;
  final String parkingName;
  final String parkingUrl;
  final Map address;
  final int price;
  final List review;
  final String startDate;
  final String endDate;
  final TimeOfDay entryTime;
  final TimeOfDay exitTime;
  final bool isParkingFavSelect;
  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  bool isHeartSelected = false;
  final parkingAreaService = ParkingAreaService();
  final reserveService = ReserveService();
  final storage = const FlutterSecureStorage();
  final profileService = ProfileService();
  double averageReview = 0.0;
  int sumPrice = 0;
  double quantityHour = 0.0;
  late DateTime currentTime;
  late Profile? profile;
  bool _isLoadProfile = false;
  bool _isClickToSummary = false;

  @override
  void initState() {
    super.initState();
    averageReview =
        parkingAreaService.calculateAverageReviewScore(widget.review);
    sumPrice = reserveService.calculateParkingPrice(widget.startDate,
        widget.entryTime, widget.endDate, widget.exitTime, widget.price);
    quantityHour = reserveService.calculateParkingHour(widget.startDate,
        widget.entryTime, widget.endDate, widget.exitTime, widget.price);
    loadProfile();
    isHeartSelected = widget.isParkingFavSelect;
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
    if (_isClickToSummary) {
      EasyLoading.dismiss();
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingSummary(
            parkingID: widget.parkingID,
            providerID: widget.providerID,
            parkingName: widget.parkingName,
            parkingAddress:
                '${widget.address['address_text']} ${widget.address['sub_district']} ${widget.address['district']} ${widget.address['province']} ${widget.address['postal_code']}',
            startDate: widget.startDate,
            endDate: widget.endDate,
            entryTime: widget.entryTime,
            exitTime: widget.exitTime,
            price: widget.price,
            cashback: profile!.cashback,
            quantity: quantityHour,
            sumPrice: sumPrice,
          ),
        ),
      );
    }
  }

  void openGoogleMap(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("การจอง"),
          centerTitle: true,
          backgroundColor: AppColor.appPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 430,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.5),
                        child: Container(
                          color: Colors.grey[200],
                          child: PageView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Image.network(
                                (widget.parkingUrl),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
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
                                  widget.parkingID, "pull");
                              EasyLoading.dismiss();
                              EasyLoading.showSuccess("นำที่จอดรถออกเรียบร้อย");
                            } else {
                              await parkingAreaService.pushPullFavoriteParking(
                                  widget.parkingID, "push");
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
                    Text(
                      widget.parkingName,
                      style: const TextStyle(fontSize: 24),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        openGoogleMap(widget.address['latitude'],
                            widget.address['longitude']);
                      },
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'แผนที่',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.appPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${widget.address['address_text']} ${widget.address['sub_district']} ${widget.address['district']} ${widget.address['province']} ${widget.address['postal_code']}',
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColor.appYellow),
                    const SizedBox(width: 5.0),
                    Text("$averageReview",
                        style: const TextStyle(fontSize: 14.0)),
                    const SizedBox(width: 20.0),
                    Text('${widget.review.length} รีวิว',
                        style: const TextStyle(fontSize: 14.0)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2.0),
                Column(
                  children: widget.review.map((review) {
                    return ReviewItem(
                      review: review,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 100),
                PurpleButton(
                    label: "จองที่จอดรถ",
                    onPressed: () {
                      if (_isLoadProfile) {
                        EasyLoading.show();
                        setState(() {
                          _isClickToSummary = true;
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParkingSummary(
                              parkingID: widget.parkingID,
                              providerID: widget.providerID,
                              parkingName: widget.parkingName,
                              parkingAddress:
                                  '${widget.address['address_text']} ${widget.address['sub_district']} ${widget.address['district']} ${widget.address['province']} ${widget.address['postal_code']}',
                              startDate: widget.startDate,
                              endDate: widget.endDate,
                              entryTime: widget.entryTime,
                              exitTime: widget.exitTime,
                              price: widget.price,
                              cashback: profile!.cashback,
                              quantity: quantityHour,
                              sumPrice: sumPrice,
                            ),
                          ),
                        );
                      }
                    }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}

class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, required this.review});
  final Map review;

  String calculateTimeDifference(timestampString) {
    DateTime commentTime = DateTime.parse(timestampString);
    DateTime currentTime = DateTime.now();

    Duration difference = currentTime.difference(commentTime);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) {
        return "${difference.inMinutes} นาทีที่แล้ว";
      }
      return "${difference.inHours} ชั่วโมงที่แล้ว";
    } else {
      return "${difference.inDays} วันที่แล้ว";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${review['first_name']} ${review['last_name']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(calculateTimeDifference(review['time_stamp']))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review['review_score'] ? Icons.star : Icons.star,
                color: index < review['review_score']
                    ? Colors.yellow
                    : Colors.grey,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 5),
          Text(review['comment']),
          const Divider(),
        ],
      ),
    );
  }
}
