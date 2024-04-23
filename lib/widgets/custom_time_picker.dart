import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final bool isEntryTime;
  final TimeOfDay initialTime;
  final TimeOfDay entryTime;
  final Function(TimeOfDay) onTimeChanged;
  final Function(String) onSelectedDateChanged;
  final String selectedDate;

  const CustomTimePicker({
    super.key,
    required this.isEntryTime,
    required this.initialTime,
    required this.entryTime,
    required this.onTimeChanged,
    required this.onSelectedDateChanged,
    required this.selectedDate,
  });

  @override
  CustomTimePickerState createState() => CustomTimePickerState();
}

class CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour;
  late int selectedMinuteIndex;
  late DateTime startDate;
  late DateTime endDate;

  List<int> get minuteOptions => [0, 30];

  @override
  void initState() {
    super.initState();
    initTime();
    initDate();
  }

  void initTime() {
    final init = widget.initialTime;
    if (widget.isEntryTime) {
      selectedHour = init.hour;
    } else {
      if (widget.entryTime.hour == 23) {
        selectedHour = 0;
      } else {
        selectedHour = init.hour + 1;
      }
    }
    if (init.minute == 0) {
      selectedMinuteIndex = 0;
    } else {
      selectedMinuteIndex = 1;
    }
  }

  void initDate() {
    final initDate = widget.selectedDate;
    List dateList = initDate.split(" - ");
    for (int i = 0; i < dateList.length; i++) {
      List<String> dateParts = dateList[i].split('-');
      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);
      if (i == 1) {
        startDate = DateTime(year, month, day);
      } else {
        endDate = DateTime(year, month, day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Hours
        Expanded(
          child: DropdownButton<int>(
            value: selectedHour,
            onChanged: (int? newValue) {
              final now = widget.initialTime;
              if (widget.isEntryTime) {
                if (newValue! < now.hour ||
                    (newValue == now.hour && now.minute >= 30)) {
                  // ตั้งค่าให้เป็นเวลาปัจจุบันถ้าเลือกชั่วโมงย้อนหลัง
                  // selectedHour = now.hour;

                  selectedHour = newValue;
                  selectedMinuteIndex = now.minute >= 30 ? 1 : 0;
                } else {
                  selectedHour = newValue;
                }
              } else {
                if ((newValue! - widget.entryTime.hour) < 1) {
                  // ตั้งค่าให้เป็นเวลาปัจจุบันถ้าเลือกชั่วโมงย้อนหลัง
                  selectedHour = widget.entryTime.hour + 1;
                  selectedMinuteIndex = widget.entryTime.minute >= 30 ? 1 : 0;
                } else {
                  selectedHour = newValue;
                }
              }
              updateTime();
            },
            items: List<DropdownMenuItem<int>>.generate(
              24,
              (int index) => DropdownMenuItem<int>(
                value: index,
                child: Text('$index'),
              ),
            ),
          ),
        ),
        Expanded(
          child: DropdownButton<int>(
            value: minuteOptions[selectedMinuteIndex],
            onChanged: (int? newValue) {
              final now = widget.initialTime;
              if (selectedHour == now.hour &&
                  newValue! < now.minute &&
                  now.minute > 30) {
                // ไม่อนุญาตให้เลือกนาทีย้อนหลัง
                return;
              } else {
                selectedMinuteIndex = minuteOptions.indexOf(newValue!);
              }
              updateTime();
            },
            items: minuteOptions
                .map<DropdownMenuItem<int>>(
                  (int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString().padLeft(2, '0')),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void updateTime() {
    final now = widget.initialTime;
    final newTime = TimeOfDay(
        hour: selectedHour, minute: minuteOptions[selectedMinuteIndex]);

    if (newTime.hour < now.hour ||
        (newTime.hour == now.hour && newTime.minute < now.minute)) {
      return;
    }

    widget.onTimeChanged(newTime);
  }
}
