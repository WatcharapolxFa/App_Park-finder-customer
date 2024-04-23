import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/parking_area_model.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/widgets/parking/favorite_parking_card.dart';

class FavoriteCarParkScreen extends StatefulWidget {
  const FavoriteCarParkScreen({super.key});
  @override
  FavoriteCarParkState createState() => FavoriteCarParkState();
}

class FavoriteCarParkState extends State<FavoriteCarParkScreen> {
  final parkingAreaService = ParkingAreaService();
  final storage = const FlutterSecureStorage();
  List<ParkingArea> parkingAreaList = [];
  bool _isLoadParking = false;

  @override
  void initState() {
    super.initState();
    _loadParkingArea();
  }

  void _loadParkingArea() async {
    setState(() {
      _isLoadParking = true;
    });
    try {
      final parkingAreas = await parkingAreaService.getParkingAreaFavorite();
      if (!mounted) return;
      setState(() {
        parkingAreaList = parkingAreas;
        _isLoadParking = false;
      });
    } catch (err) {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ที่จอดรถโปรด'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadParking)
              const CupertinoPopupSurface(
                isSurfacePainted: false,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ...parkingAreaList.map((data) => CarParkCard(
                  title: data.parkingName,
                  address:
                      "${data.address['address_text']} ${data.address['sub_district']} ${data.address['district']} ${data.address['province']}",
                  rating: parkingAreaService
                      .calculateAverageReviewScore(data.review),
                  reviewCount: data.review.length,
                )),
          ],
        ),
      ),
    );
  }
}
