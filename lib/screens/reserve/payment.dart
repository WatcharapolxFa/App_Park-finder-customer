import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:parkfinder_customer/screens/reserve/status_pending.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.parkingID,
    required this.providerID,
    required this.parkingName,
    required this.carID,
    required this.startDate,
    required this.endDate,
    required this.entryTime,
    required this.exitTime,
    required this.sumPrice,
    required this.quantity,
    required this.price,
    required this.cashbackUsed,
  });
  final String parkingID;
  final String providerID;
  final String parkingName;
  final String carID;
  final String startDate;
  final String endDate;
  final TimeOfDay entryTime;
  final TimeOfDay exitTime;
  final int sumPrice;
  final double quantity;
  final int price;
  final int cashbackUsed;
  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  final reserveService = ReserveService();

  Widget getField() {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 5,
                color: Colors.grey.withOpacity(0.3),
                offset: const Offset(0, 2))
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  // width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          color: Colors.grey.withOpacity(0.25),
                          offset: const Offset(0, 2))
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Image.asset(
                    'lib/assets/icons/LinePay.png',
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const Text("Rabbit LINE Pay"),
              ],
            ),
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF097969),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('วิธีการชำระเงิน'),
          centerTitle: true,
          backgroundColor: const Color(0xFF6828DC),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              children: [
                Container(
                  child: getField(),
                ),
                const SizedBox(
                  height: 20,
                ),
                PurpleButton(
                  label: "ดำเนินการต่อ",
                  onPressed: () async {
                    EasyLoading.show();
                    final responseReserve = await reserveService.createReserve(
                        widget.providerID,
                        widget.parkingID,
                        widget.carID,
                        widget.startDate,
                        widget.endDate,
                        widget.entryTime,
                        widget.exitTime,
                        widget.sumPrice);

                    if (responseReserve != null) {
                      final orderID = responseReserve['order_id'];
                      final responseTransaction =
                          await reserveService.createTransaction(
                              widget.providerID,
                              orderID,
                              widget.parkingID,
                              widget.parkingName,
                              widget.quantity,
                              widget.price,
                              widget.cashbackUsed);

                      if (responseTransaction['message'] ==
                          "Success payment with cashback") {
                        EasyLoading.dismiss();
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamed(context, '/succeed');
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
                    }
                    EasyLoading.dismiss();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
