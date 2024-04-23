import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';

class CarParkCard extends StatelessWidget {
  final String title;
  final String address;
  final double rating;
  final int reviewCount;

  const CarParkCard({
    super.key,
    required this.title,
    required this.address,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ปรับให้เหมาะสมตามความต้องการ
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColor.appPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // ระยะห่างระหว่างไอคอนกับข้อมูล
                Expanded(
                  // ใช้ Expanded เพื่อให้ส่วนข้อมูลขยายเต็มพื้นที่ที่เหลือ
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColor.appStatusRed,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.appGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColor.appYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "$rating ($reviewCount)",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.appGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
          ],
        ));
  }
}
