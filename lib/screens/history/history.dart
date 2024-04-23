import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/widgets/history/history_card.dart';
import '../../assets/colors/constant.dart';
import 'package:logger/logger.dart';
import 'package:parkfinder_customer/services/history_service.dart';
import 'package:parkfinder_customer/models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  HistorySuccessScreenState createState() => HistorySuccessScreenState();
}

class HistorySuccessScreenState extends State<HistoryScreen> {
  final historyService = HistoryService();
  final storage = const FlutterSecureStorage();
  late String selectedStatus;
  late String selectStatusAPI;
  int index = 0;
  List<History> historyList = [];
  final logger = Logger();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = 'กำลังดำเนินการ';
    selectStatusAPI = "on_working";
    _loadHistory("on_working");
  }

  void _loadHistory(String status) async {
    setState(() {
      _isLoading = true;
    });
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final histories = await historyService.getHistory(status, accessToken);
      if (!mounted) return;
      setState(() {
        historyList = histories;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติคำสั่งซื้อ"),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton('กำลังดำเนินการ'),
                _buildStatusButton('เสร็จสิ้น'),
                _buildStatusButton('ยกเลิก/ล้มเหลว'),
              ],
            ),
            const Divider(thickness: 1),
            ...historyList.map((history) => HistoryCard(history: history)),
            if (_isLoading)
              const CupertinoPopupSurface(
                isSurfacePainted: false,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    bool isSelected = selectedStatus == status;
    return TextButton(
      onPressed: () {
        setState(() {
          historyList = [];
          selectedStatus = status;
          selectStatusAPI = _mapStatusToAPI(status);
          _loadHistory(
              selectStatusAPI); // โหลดข้อมูลใหม่ทุกครั้งที่มีการเปลี่ยนแปลง status
        });
      },
      child: Text(
        status,
        style: TextStyle(
            color:
                isSelected ? AppColor.appPrimaryColor : const Color(0xFFB2B2B2),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 18),
      ),
    );
  }

  String _mapStatusToAPI(String status) {
    switch (status) {
      case 'กำลังดำเนินการ':
        return "on_working";
      case 'เสร็จสิ้น':
        return "successful";
      case 'ยกเลิก/ล้มเหลว':
        return "fail";
      default:
        return "";
    }
  }
}
