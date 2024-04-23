import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parkfinder_customer/screens/reserve/my_location.dart';
import 'package:parkfinder_customer/services/reserve_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key, required this.reserveID});
  final String reserveID;
  @override
  ScanQrPageState createState() => ScanQrPageState();
}

class ScanQrPageState extends State<ScanQrPage> {
  final GlobalKey qrKey = GlobalKey();
  final reserveService = ReserveService();
  QRViewController? controller;
  String? qrText;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appPrimaryColor,
        centerTitle: true,
        title: const Text('QR Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // ไอคอน X
          onPressed: () {
            Navigator.pop(context); // ย้อนกลับหน้า Home
            Navigator.pushNamed(context, "/logged_in");
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _isLoading ? (p0) {} : _onQRViewCreated,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(''),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isLoading == false) {
        if (scanData.code != null) {
          setState(() {
            qrText = scanData.code;
            _isLoading = true;
          });
          controller.pauseCamera();
          EasyLoading.show();
          if (scanData.code!
              .startsWith("http://34.125.122.199/customer/start_reserve")) {
            final response = await reserveService.scanQRCode(scanData.code!);

            if (response) {
              final reserveDetail =
                  await reserveService.getReserveDetailwithID(widget.reserveID);

              if (reserveDetail != null) {
                EasyLoading.dismiss();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyLocationPage(
                              reserveID: reserveDetail.reserveID,
                              providerID: reserveDetail.providerID,
                              providerName: reserveDetail.providerName,
                              orderID: reserveDetail.orderID,
                              parkingName: reserveDetail.parkingName,
                              dateStart: reserveDetail.dateStart,
                              dateEnd: reserveDetail.dateEnd,
                              hourStart: reserveDetail.hourStart,
                              hourEnd: reserveDetail.hourEnd,
                              minStart: reserveDetail.minStart,
                              minEnd: reserveDetail.minEnd,
                              latitude: reserveDetail.latitude,
                              longitude: reserveDetail.longitude,
                            )));
              }
            }
          }
          controller.resumeCamera();
          EasyLoading.dismiss();
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
