import 'dart:convert';
import 'package:project_skripsi/screen/auth/login_screen.dart';
import 'package:intl/intl.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/dialog_constant.dart';
import '../../../controller/edit_profile_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';
import '../../../utils/local_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Uint8List? _imageData;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController pointsController;
  Map<String, String> listController = {};
  String points = "0";
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    pointsController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    String? email = await LocalData.getData('email');
    String? fullName = await LocalData.getData('full_name');

    String? phone = await LocalData.getData('phone');
    String? pointValue = await LocalData.getData('point');
    Uint8List image = await LocalData.getProfilePicture("profile_picture");
    emailController.text = email;
    nameController.text = fullName ?? "";
    phoneController.text = phone;
    points = pointValue;
    pointsController.text = points; // Set points in the controller
    _imageData ??= image;
  }

  Future<void> _pickImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog

                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    _imageData =
                        await pickedImage.readAsBytes(); // Convert to bytes
                    setState(() {
                      _imageData = _imageData;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog

                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    _imageData =
                        await pickedImage.readAsBytes(); // Convert to bytes
                    setState(() {
                      _imageData = _imageData;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Information',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _confirmEditProfile(),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3E5FC), // Light blue
              Color.fromARGB(255, 61, 192, 253), // Medium light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ), // Slightly darker background color
        child: FutureBuilder(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (mounted) {
                            _pickImage(context);
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              ClipOval(
                                child: Image.memory(
                                  _imageData!,
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue, // Background warna biru
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white, // Warna ikon putih
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCircularTextField(nameController, 'Name',
                          isReadOnly: true),
                      const SizedBox(height: 15),
                      _buildCircularTextField(emailController, 'Email'),
                      const SizedBox(height: 15),
                      _buildCircularTextField(
                          phoneController, 'Phone'), // Read-only phone field
                      const SizedBox(height: 15),
                      _buildCircularTextField(pointsController, 'Points',
                          isReadOnly: true,
                          color: Colors.pink,
                          point: true), // Read-only points field
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircularTextField(TextEditingController controller, String label,
      {bool isOptional = false,
      bool isReadOnly = false,
      Color? color,
      bool point = false}) {
    if (point) {
      double? value = double.tryParse(
          controller.text.replaceAll(',', '')); // Menghapus koma
      if (value != null) {
        controller.text = currencyFormatter.format(value);

        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            style: TextStyle(color: color ?? null),
            readOnly: isReadOnly,
            decoration: InputDecoration(
              labelText: "\t\t$label",
              labelStyle: const TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.isEmpty)) {
                return ('\n\t\tPlease enter your $label\n');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _confirmEditProfile() {
    Get.dialog(
      AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Do you really want to update your profile?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog tanpa update
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog sebelum lanjut
              _saveProfile(); // Jalankan update
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    Uint8List? lateImage;

    // Fetch data asynchronously
    Uint8List image = await LocalData.getProfilePicture("profile_picture");

    // Assign the fetched image data to lateImage
    setState(() {
      lateImage = image;
    });
    if (lateImage != _imageData) {
      listController['profile_picture'] = base64Encode(_imageData as Uint8List);
    }

    // Check if the image has been changed and update the listController

    // Update other profile fields
    listController['email'] = emailController.text;
    listController['name'] = nameController.text;
    listController['phone'] = phoneController.text;
    listController['username'] = await LocalData.getData('user');
    print(listController.keys);
    if (_formKey.currentState!.validate()) {
      EditProfileController().postEditProfile(
          context: context,
          callback: (result, error) {
            if (result != null && result['error'] != true) {
              setState(() {
                LocalData.saveData('email', listController['email']!);
                LocalData.saveData('phone', listController['phone']!);
                LocalData.saveData('full_name', listController['name']!);
                LocalData.saveData(
                    'profile_picture', listController['profile_picture']!);
              });
              Get.snackbar('Success', 'Profile updated successfully!',
                  colorText: Colors.white,
                  icon: const Icon(
                    Icons.check,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  backgroundColor: const Color.fromARGB(83, 0, 0, 0),
                  snackPosition: SnackPosition.BOTTOM);
              if (result['phone'] == true) {
                Get.offAll(LoginScreen());
              }
            } else {
              print(error);
              DialogConstant.alert('Maaf ada kesalahan');
            }
          },
          post: listController);
    }
  }
}
