import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:parkfinder_customer/screens/search/search_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../assets/colors/constant.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen(
      {super.key, required this.currentPosition, required this.isBookingNow});  
  final Position currentPosition;
  final bool isBookingNow;
  
  @override
  State<StatefulWidget> createState() {
    return _FilterScreenState();
  }
}

class _FilterScreenState extends State<FilterScreen> {
  TextEditingController keywordController = TextEditingController();
  String selectedDate = ''; // สำหรับเก็บวันที่ที่เลือก
  late int selectedStartHour;
  late int selectedStartMinuteIndex;
  late int selectedEndHour;
  late int selectedEndMinuteIndex;
  late DateTime startDate;
  late DateTime endDate;
  List<int> startHourRange = [0, 0];
  List<int> endHourRange = [0, 0];
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;
  TimeOfDay? initTime;
  List<int> get minuteOptions => [0, 30];

  int selectedStars = 0;
  @override
  void initState() {
    super.initState();
    _setupInitialTimes();

    DateTime initDateTime_1 = DateTime.now();
    DateTime initDateTime_2 = DateTime.now();
    if (DateTime.now().hour >= 23) {
      initDateTime_2 = initDateTime_2.add(const Duration(days: 1));
      if (DateTime.now().minute >= 30) {
        initDateTime_1 = initDateTime_1.add(const Duration(days: 1));
      }
    }
    startDate = initDateTime_1;
    endDate = initDateTime_2;
    selectedDate =
        "${DateFormat('yyyy-MM-dd').format(initDateTime_1)} - ${DateFormat('yyyy-MM-dd').format(initDateTime_2)}";

    initTimeT();
    setState(() {
      selectedPrice = 1; // Set initial price to 1
      selectedStars = 1; // Set initial stars to 1
    });
  }

  void initTimeT() {
    final init = initTime;

    selectedStartHour = init!.hour;
    if (startDate.day == DateTime.now().day) {
      startHourRange[0] = selectedStartHour;
      startHourRange[1] = 23;
    }

    if (init.hour == 23) {
      selectedEndHour = 0;
      if (startDate.day == DateTime.now().day) {
        endHourRange[0] = selectedEndHour;
        endHourRange[1] = 23;
      }
    } else {
      selectedEndHour = init.hour + 1;
      if (startDate.day == DateTime.now().day) {
        endHourRange[0] = selectedEndHour;
        endHourRange[1] = 23;
      }
    }

    if (init.minute == 0) {
      selectedStartMinuteIndex = 0;
      selectedEndMinuteIndex = 0;
    } else {
      selectedStartMinuteIndex = 1;
      selectedEndMinuteIndex = 1;
    }
  }

  void _setupInitialTimes() {
    DateTime now = DateTime.now();
    // ตรวจสอบเงื่อนไขเวลา 23.00 ขึ้นไป
    if (now.hour >= 23) {
      // ตั้งค่า exitTime ให้เป็นชั่วโมงแรกของวันถัดไป
      entryTime = TimeOfDay(
          hour: now.minute >= 30 ? 0 : 23, minute: now.minute >= 30 ? 0 : 30);
      exitTime =
          TimeOfDay(hour: now.minute >= 30 ? 1 : 0, minute: entryTime!.minute);
      // จำเป็นต้องเลือกวันที่อย่างน้อย 2 วันใน selectDate
    } else {
      // ตั้งค่าปกติหากเวลาน้อยกว่า 23.00  22:20 22:30 23:30
      entryTime = TimeOfDay(
          hour: now.minute >= 30 ? now.hour + 1 : now.hour,
          minute: now.minute >= 30 ? 0 : 30);
      exitTime = TimeOfDay(
          hour: now.minute >= 30 ? now.hour + 2 : now.hour + 1,
          minute: entryTime!.minute);
    }
    initTime = entryTime;
  }

  void selectDate() async {
    DateTime now = DateTime.now();
    final DateTime firstDate = now;
    DateTime initialDate = now;
    final DateTime lastDate = widget.isBookingNow
        ? now.add(const Duration(days: 7))
        : DateTime(now.year + 1);
    // ตรวจสอบหากเวลาปัจจุบันเป็น 23.00 ขึ้นไป
    if (now.hour >= 23) {
      // กำหนดให้ initialDate เป็นวันถัดไป
      initialDate = now.add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        // หากเวลาปัจจุบันเป็น 23.00 ขึ้นไปและเลือกวันเดียว, บังคับให้เลือกอย่างน้อย 2 วัน
        if (now.hour >= 23 && pickedDate.difference(now).inDays < 1) {
          selectedDate =
              '${DateFormat('yyyy-MM-dd').format(pickedDate)} - ${DateFormat('yyyy-MM-dd').format(pickedDate.add(const Duration(days: 1)))}';
        } else {
          selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      });
    }
  }

  void updateExitTime() {
    if (entryTime != null) {
      final newExitTime = TimeOfDay(
          hour: (entryTime!.hour + 1) % 24, minute: entryTime!.minute);
      setState(() {
        exitTime = newExitTime;
      });
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          selectedStars = index + 1;
        });
      },
      icon: Icon(
        Icons.star,
        color: (index < selectedStars) ? AppColor.appYellow : Colors.grey,
      ),
    );
  }

  int selectedPrice = 0;

  Widget _priceButton(String price) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
        backgroundColor: selectedPrice == price.length
            ? AppColor.appPrimaryColor
            : Colors.transparent,
        foregroundColor:
            selectedPrice == price.length ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedPrice = price.length;
        });
      },
      child: Text(price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("เลือกการจองของคุณ"),
          ),
          centerTitle: true,
          backgroundColor: AppColor.appPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ค้นหาที่จอดรถของคุณ'),
                const SizedBox(height: 15.0),
                TextField(
                  controller: keywordController,
                  decoration: const InputDecoration(
                    hintText: 'กรอกเพื่อค้นหา...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 10.0, // ความหนาของขอบ
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Divider(thickness: 2),
                const SizedBox(height: 20.0),
                const Text('วันที่เข้าจอด'),
                const SizedBox(height: 15.0),
                Row(
                  children: [
                    Expanded(
                        child: TextButton(
                      onPressed: () async {
                        DateTimeRange? pickedDateRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: widget.isBookingNow
                              ? DateTime.now().add(const Duration(days: 7))
                              : DateTime.now().add(const Duration(days: 365)),
                        );

                        if (pickedDateRange != null) {
                          setState(() {
                            startDate = pickedDateRange.start;
                            endDate = pickedDateRange.end;
                            if (startDate.day != DateTime.now().day) {
                              startHourRange[0] = 0;
                              endHourRange[0] = 0;
                              _setupInitialTimes();
                              initTimeT();
                            } else {
                              _setupInitialTimes();
                              initTimeT();
                            }
                            selectedDate =
                                '${DateFormat('yyyy-MM-dd').format(pickedDateRange.start)} - ${DateFormat('yyyy-MM-dd').format(pickedDateRange.end)}';
                          });
                        }
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          const BorderSide(
                              width: 1, color: Colors.black), // ความหนาของขอบ
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(
                              11, 10, 11, 10), // Padding ภายใน TextButton
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // ขอบแบน
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // ชิดขอบทั้งสองด้าน
                        children: [
                          Text(
                            selectedDate.isEmpty
                                ? 'เลือกวันที่คุณทำการการจองที่จอด'
                                : selectedDate, // แสดงวันที่ถ้าเลือกแล้ว
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 24.0), // Icon วางทางด้านขวา
                        ],
                      ),
                    ))
                  ],
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('เวลาเข้าและออกจากที่จอดรถ',
                        textAlign: TextAlign.left),
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton(
                                    value: selectedStartHour,
                                    onChanged: (newValue) {
                                      if (startDate.day != DateTime.now().day) {
                                        setState(() {
                                          endHourRange[0] = 0;
                                          selectedStartHour = newValue!;
                                        });
                                      } else {
                                        if (newValue! < DateTime.now().hour) {
                                          if (DateTime.now().minute >= 30) {
                                            setState(() {
                                              selectedStartHour =
                                                  DateTime.now().hour + 1;
                                            });
                                          } else {
                                            setState(() {
                                              selectedStartHour =
                                                  DateTime.now().hour;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            if (startDate.day == endDate.day) {
                                              endHourRange[0] = newValue + 1;
                                            }
                                            selectedStartHour = newValue;
                                          });
                                        }
                                      }
                                      if ((startDate.day == endDate.day) &&
                                          (selectedEndHour - selectedStartHour <
                                              1)) {
                                        if (selectedStartHour != 23) {
                                          endHourRange[0] =
                                              selectedStartHour + 1;
                                          selectedEndHour =
                                              selectedStartHour + 1;
                                        } else {
                                          setState(() {
                                            endHourRange[0] = 0;
                                            selectedEndHour = 00;
                                            endDate = endDate
                                                .add(const Duration(days: 1));
                                            selectedDate =
                                                '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                          });
                                        }
                                      }
                                    },
                                    items: List<DropdownMenuItem<int>>.generate(
                                      startHourRange[1] - startHourRange[0] + 1,
                                      (int index) => DropdownMenuItem<int>(
                                        value: index + startHourRange[0],
                                        child: Text((index + startHourRange[0])
                                            .toString()
                                            .padLeft(2, '0')),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButton(
                                    value:
                                        minuteOptions[selectedStartMinuteIndex],
                                    onChanged: (newValue) {
                                      if (startDate.day != DateTime.now().day) {
                                        setState(() {
                                          selectedStartMinuteIndex =
                                              minuteOptions.indexOf(newValue!);
                                        });
                                      } else {
                                        if (selectedStartHour ==
                                            DateTime.now().hour) {
                                          if (DateTime.now().minute >= 30) {
                                            setState(() {
                                              selectedStartMinuteIndex = 0;
                                            });
                                          } else {
                                            setState(() {
                                              selectedStartMinuteIndex = 1;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            selectedStartMinuteIndex =
                                                minuteOptions
                                                    .indexOf(newValue!);
                                          });
                                        }
                                      }
                                      if (startDate.day == endDate.day) {
                                        if (selectedEndHour -
                                                selectedStartHour ==
                                            1) {
                                          if (newValue == 30) {
                                            setState(() {
                                              selectedEndMinuteIndex = 1;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    items: minuteOptions
                                        .map<DropdownMenuItem<int>>(
                                          (int value) => DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value
                                                .toString()
                                                .padLeft(2, '0')),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(width: 20.0),
                        Expanded(
                            child: Row(
                          children: [
                            Expanded(
                              child: DropdownButton(
                                value: selectedEndHour,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedEndHour = newValue!;
                                  });
                                },
                                items: List<DropdownMenuItem<int>>.generate(
                                  endHourRange[1] - endHourRange[0] + 1,
                                  (int index) => DropdownMenuItem<int>(
                                    value: index + endHourRange[0],
                                    child: Text((index + endHourRange[0])
                                        .toString()
                                        .padLeft(2, '0')),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton(
                                value: minuteOptions[selectedEndMinuteIndex],
                                onChanged: (newValue) {
                                  if (startDate.day == endDate.day) {
                                    if (selectedEndHour - selectedStartHour ==
                                        1) {
                                      if (selectedStartMinuteIndex == 1) {
                                        setState(() {
                                          selectedEndMinuteIndex = 1;
                                        });
                                      } else {
                                        setState(() {
                                          selectedEndMinuteIndex =
                                              minuteOptions.indexOf(newValue!);
                                        });
                                      }
                                    }
                                  }
                                },
                                items: minuteOptions
                                    .map<DropdownMenuItem<int>>(
                                      (int value) => DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                            value.toString().padLeft(2, '0')),
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Divider(thickness: 2.0),
                const SizedBox(height: 20.0),
                const Text('ราคา/ชั่วโมง'),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _priceButton('฿'),
                    _priceButton('฿฿'),
                    _priceButton('฿฿฿'),
                    _priceButton('฿฿฿฿'),
                    _priceButton('฿฿฿฿฿'),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text('คะแนนรีวิวสถานที่จอด'),
                Column(
                  children: [
                    const SizedBox(height: 15.0),
                    Row(
                      children: List.generate(5, (index) => buildStar(index)),
                    ),
                  ],
                ),
                const SizedBox(height: 50.0),
                Center(
                  child: PurpleButton(
                    label: "ค้นหาที่จอด",
                    onPressed: () {
                      // เพิ่มเงื่อนไขตรวจสอบค่า
                      if (selectedPrice == 0 || selectedStars == 0) {
                        // แสดงข้อความแจ้งเตือนหากไม่ผ่านเงื่อนไข
                        EasyLoading.showInfo(
                            'กรุณาเลือกราคาและคะแนนรีวิวสถานที่จอด');
                        return; // ออกจากฟังก์ชันเพื่อไม่ให้ดำเนินการต่อ
                      }

                      // ดำเนินการต่อหากผ่านเงื่อนไขทั้งหมด
                      List<String> date = selectedDate.split(' - ');
                      String startDate = date[0];
                      String endDate = date[1];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchMapPage(
                            keyword: keywordController.text,
                            review: selectedStars,
                            price: selectedPrice,
                            startDate: startDate,
                            endDate: endDate,
                            entryTime: TimeOfDay(
                                hour: selectedStartHour,
                                minute:
                                    minuteOptions[selectedStartMinuteIndex]),
                            exitTime: TimeOfDay(
                                hour: selectedEndHour,
                                minute: minuteOptions[selectedEndMinuteIndex]),
                            currentPosition: widget.currentPosition,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
