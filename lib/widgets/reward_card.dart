import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? expiryDate;
  final int? customerExpiryDate;
  final String imageUrl;

  const RewardCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.expiryDate,
    this.customerExpiryDate,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      width: 380.0,
      height: 125.0,
      decoration: BoxDecoration(
        color: AppColor.appPrimaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: RichText(
                    text: const TextSpan(
                      text: 'PARKFINDER\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: 'REWARD',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    expiryDate != null
                        ? 'หมดอายุ ${DateFormat('d/MM/yyyy').format(DateTime.parse(expiryDate!))}'
                        : 'เหลือเวลาอีก $customerExpiryDate ชั่วโมง',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.network(
            imageUrl,
            width: 200,
            height: 120,
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
