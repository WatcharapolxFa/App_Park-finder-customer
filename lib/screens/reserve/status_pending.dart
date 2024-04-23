import 'package:flutter/material.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../assets/colors/constant.dart';

class StatusPendingScreen extends StatefulWidget {
  const StatusPendingScreen({
    super.key,
    // this.paymentURL,
    required this.reserveID,
  });
  // final String? paymentURL;
  final String reserveID;

  @override
  StatusPendingState createState() => StatusPendingState();
}

class StatusPendingState extends State<StatusPendingScreen> {
  final reserveService = ReserveService();
  late String paymentURL;

  @override
  void initState() {
    super.initState();
    loadCacheUrl();
  }

  void loadCacheUrl() async {
    List<String>? data = await reserveService.getCachedUrl(widget.reserveID);
    Duration difference = DateTime.parse(data![1]).difference(DateTime.now());
    if (difference.inSeconds < 1200) {
      setState(() {
        paymentURL = data[0];
      });
    } else {
      await reserveService.removeUrl(widget.reserveID);
    }
  }

  void openLinePay() async {
    final Uri url = Uri.parse(paymentURL);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/status_panding.png',
                width: 142,
                height: 142,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'รอการชำระเงิน',
                style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: AppColor.appPrimaryColor),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'ธุรกรรมการชำระเงิน\nของคุณกำลังทำรายการ',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFFA6AAB4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              const SizedBox(height: 100.0),
              const SizedBox(height: 100.0),
              PurpleButton(
                label: 'จ่ายเงิน',
                onPressed: () {
                  openLinePay();
                  // getUrlPayment();
                  // ignore: use_build_context_synchronously
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacementNamed(context, '/logged_in');
                  // Navigator.pop(context); // ย้อนกลับหน้าก่อนหน้า
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
