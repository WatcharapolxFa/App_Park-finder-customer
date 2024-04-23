import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:parkfinder_customer/screens/logged-in/index.dart';
import 'dart:convert';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';

class ProfileEditPage extends StatefulWidget {
  final String profileID;
  final String name;
  final String lastName;
  final String phoneNumber;
  final String idCard;
  final String birthDay;
  final String profileURL;
  final VoidCallback onEdit;

  const ProfileEditPage(
      {super.key,
      required this.profileID,
      required this.name,
      required this.lastName,
      required this.phoneNumber,
      required this.idCard,
      required this.birthDay,
      required this.profileURL,
      required this.onEdit});

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  final storage = const FlutterSecureStorage();
  ImagePicker picker = ImagePicker();
  XFile? image;
  late Uint8List imageByte;

  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idCardController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    lastNameController.text = widget.lastName;
    phoneController.text = widget.phoneNumber;
    idCardController.text = widget.idCard;
    if (widget.birthDay.isNotEmpty) {
      selectedDate = DateFormat('yyyy-MM-DD').parse(widget.birthDay);
    }
  }

  void onSavePressed() {
    // ตรวจสอบค่าว่าง
    if (nameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        idCardController.text.isEmpty ||
        selectedDate == null) {
      EasyLoading.showError("กรุณากรอกข้อมูลให้ครบถ้วน และถูกต้อง");
      return;
    }

    // ตรวจสอบเบอร์โทรศัพท์
    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      EasyLoading.showError(
          "เบอร์โทรศัพท์ไม่ถูกต้อง กรุณากรอกเป็นตัวเลข 10 หลัก");
      return;
    }

    // ตรวจสอบรหัสประชาชน
    if (!RegExp(r'^\d{13}$').hasMatch(idCardController.text)) {
      EasyLoading.showError(
          'รหัสประชาชนไม่ถูกต้อง กรุณากรอกเป็นตัวเลข 13 หลัก');
      return;
    }

    // ถ้าผ่านเงื่อนไขทั้งหมด
    EasyLoading.show();
    if (image != null) {
      uploadFormData();
    } else {
      String profileURL = "";
      if (widget.profileURL != "") {
        profileURL =
            'https://parkingadmindata.s3.ap-southeast-1.amazonaws.com/profile/${widget.profileID}/profileIMG';
      }
      updateProfile(
          nameController.text,
          lastNameController.text,
          phoneController.text,
          idCardController.text,
          selectedDate!.toLocal().toString().split(' ')[0],
          profileURL);
    }
    
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Dialog
            },
          ),
        ],
      ),
    );
  }

  void updateProfile(String firstName, String lastName, String phone,
      String ssn, String birthDay, String profileURL) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        Map data = {
          "birth_day": birthDay,
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "profile_picture_url": profileURL,
          "ssn": ssn,
        };
        String body = json.encode(data);
        final url = Uri.parse('${dotenv.env['HOST']}/customer/profile');
        final response = await http.patch(
          url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: body,
        );
        if (response.statusCode == 200) {
          String? firstNameStorage = await storage.read(key: 'firstName');
          String? lastNameStorage = await storage.read(key: 'lastName');
          String? pictureURLStorage = await storage.read(key: 'pictureURL');

          if (firstName != firstNameStorage) {
            await storage.write(key: 'firstName', value: firstName);
          }
          if (lastName != lastNameStorage) {
            await storage.write(key: 'lastName', value: lastName);
          }
          if (profileURL != pictureURLStorage) {
            await storage.write(key: 'pictureURL', value: profileURL);
          }
          widget.onEdit();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoggedInPage(screenIndex: 4)));
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        // Failed to load data from Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
    EasyLoading.dismiss();
  }

  Future<void> uploadFormData() async {
    var formData = http.MultipartRequest(
        'POST', Uri.parse('http://34.125.122.199:3100/api/aws_s3'));

    formData.fields.addAll({
      'fileName': 'profileIMG',
      'folderName': 'profile',
      'subFolderName': widget.profileID,
    });

    formData.files.add(await http.MultipartFile.fromPath(
      'file',
      image!.path,
    ));

    // Send the request
    var response = await formData.send();

    // Check the response
    if (response.statusCode == 200) {
      imageCache.clear();
      imageCache.clearLiveImages();
      String profileURL =
          'https://parkingadmindata.s3.ap-southeast-1.amazonaws.com/profile/${widget.profileID}/profileIMG';
      updateProfile(
          nameController.text,
          lastNameController.text,
          phoneController.text,
          idCardController.text,
          selectedDate!.toLocal().toString().split(' ')[0],
          profileURL);
    } else {
      // ignore: avoid_print
      print('Upload failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("แก้ไขโปรไฟล์ส่วนตัว"),
          centerTitle: true,
          backgroundColor: const Color(0xFF6828DC),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: InkWell(
                    onTap: () async {
                      image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          image!
                              .readAsBytes()
                              .then((value) => imageByte = value);
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: image == null
                          ? widget.profileURL == ""
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                  child: const Icon(Icons.person, size: 40),
                                )
                              : Image.network(
                                  (widget.profileURL),
                                  key: ValueKey(Random().nextInt(100)),
                                  fit: BoxFit.fill,
                                  width: 100,
                                  height: 100,
                                )
                          : Image.file(
                              File(image!.path),
                              key: ValueKey(Random().nextInt(100)),
                              fit: BoxFit.fill,
                              width: 100,
                              height: 100,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อ',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0), // ปรับ padding ใน TextField
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ไม่ได้ focus
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(
                          10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ได้รับการ enable แต่ไม่ได้ focus
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF6828DC),
                          width:
                              2.0), // ปรับเปลี่ยนสีของ border เมื่อ TextField ได้รับ focus
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'นามสกุล',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0), // ปรับ padding ใน TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ไม่ได้ focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ได้รับการ enable แต่ไม่ได้ focus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF6828DC),
                            width:
                                2.0), // ปรับเปลี่ยนสีของ border เมื่อ TextField ได้รับ focus
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'เบอร์โทรศัพท์',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0), // ปรับ padding ใน TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ไม่ได้ focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ได้รับการ enable แต่ไม่ได้ focus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF6828DC),
                            width:
                                2.0), // ปรับเปลี่ยนสีของ border เมื่อ TextField ได้รับ focus
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                    controller: idCardController,
                    decoration: InputDecoration(
                      labelText: 'รหัสประชาชน',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0), // ปรับ padding ใน TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ไม่ได้ focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(
                            10.0), // ปรับเปลี่ยนรูปร่างของ border เมื่อ TextField ได้รับการ enable แต่ไม่ได้ focus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF6828DC),
                            width:
                                2.0), // ปรับเปลี่ยนสีของ border เมื่อ TextField ได้รับ focus
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                          text:
                              selectedDate?.toLocal().toString().split(' ')[0]),
                      decoration: const InputDecoration(
                        labelText: 'วันเกิด',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                Center(
                  child: PurpleButton( 
                    label: 'บันทึก',
                    onPressed: onSavePressed,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
