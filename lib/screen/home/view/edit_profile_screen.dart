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
  String originalPhoneNumber = ""; // Store original phone number
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
    originalPhoneNumber = phone ?? ""; // Store original phone number
    points = pointValue;
    pointsController.text = points; // Set points in the controller
    _imageData = image;
  }

  Future<void> _pickImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Choose Profile Picture',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade50,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text('Camera',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Take a new photo'),
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
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.shade50,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.green),
                  ),
                  title: const Text('Gallery',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Choose from gallery'),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              onPressed: () => _confirmEditProfile(),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF3B82F6), // Medium blue
              Color(0xFF60A5FA), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: FutureBuilder(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error loading data',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 120), // Space for transparent AppBar

                      // Profile Picture Section
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Profile Picture',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 15),
                              GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    _pickImage(context);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.memory(
                                          _imageData!,
                                          width: 120.0,
                                          height: 120.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4facfe),
                                              Color(0xFF00f2fe)
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildPointsBalanceCard(),

                      const SizedBox(height: 30),

                      // Form Fields
                      _buildModernTextField(
                          nameController, 'Full Name', Icons.person_rounded),
                      const SizedBox(height: 20),

                      _buildModernTextField(emailController, 'Email Address',
                          Icons.email_rounded),
                      const SizedBox(height: 20),

                      _buildModernTextField(
                          phoneController, 'Phone Number', Icons.phone_rounded),
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

  Widget _buildPointsBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFA500), // Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Points Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter
                      .format(double.tryParse(points.replaceAll(',', '')) ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isOptional = false,
    bool isReadOnly = false,
    bool isPoints = false,
  }) {
    if (isPoints) {
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
        color: Colors.white.withOpacity(isReadOnly ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        style: TextStyle(
          color: isPoints ? const Color(0xFFFFD700) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPoints ? const Color(0xFFFFD700) : Colors.white,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter your $label';
          }
          return null;
        },
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
    // Check if phone number has changed
    if (phoneController.text != originalPhoneNumber) {
      _showPhoneChangeConfirmation();
    } else {
      _showNormalConfirmation();
    }
  }

  void _showPhoneChangeConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Phone Number Changed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You have changed your phone number. This will require you to log in again for security purposes.",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Previous: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          originalPhoneNumber.isEmpty
                              ? "Not set"
                              : originalPhoneNumber,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "New: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          phoneController.text,
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Are you sure you want to continue?",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A59),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Yes, Update"),
          ),
        ],
      ),
    );
  }

  void _showNormalConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm Update",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        content: const Text(
          "Are you sure you want to update your profile information?",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    listController['email'] = emailController.text;
    listController['name'] = nameController.text;
    listController['phone'] = phoneController.text;
    listController['username'] = await LocalData.getData('user');
    Uint8List? lateImage;

    // Fetch data asynchronously
    Uint8List image = await LocalData.getProfilePicture("profile_picture");

    // Assign the fetched image data to lateImage
    setState(() {
      lateImage = image;
    });
    if (lateImage != _imageData) {
      listController['profile_picture'] = base64Encode(_imageData as Uint8List);
      LocalData.saveData('profile_picture', listController['profile_picture']!);
    }

    // Check if the image has been changed and update the listController

    // Update other profile fields

    print(listController);
    if (_formKey.currentState!.validate()) {
      EditProfileController().postEditProfile(
          context: context,
          callback: (result, error) {
            if (result != null && result['error'] != true) {
              setState(() {
                LocalData.saveData('email', listController['email']!);
                LocalData.saveData('phone', listController['phone']!);
                LocalData.saveData('full_name', listController['name']!);
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
