import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_skripsi/screen/ocr_ktp/controller/image_controller.dart';

class ImagePickerWidget extends StatelessWidget {
  final _controller = Get.put(ImagePickerController());

  ImagePickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        _controller.pickImage(ImageSource.gallery);
                        Get.back();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Camera'),
                      onTap: () {
                        _controller.pickImage(ImageSource.camera);
                        Get.back();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        //*Lingkaran yang ketika di klik memunculkan pilihan upload foto profil
        child: Obx(() => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _controller.image.existsSync()
                    ? FileImage(_controller.image)
                    : null,
                radius: 50,
                child: _controller.image.existsSync()
                    ? null
                    : const Icon(Icons.person, color: Colors.grey, size: 50),
              ),
            )));
  }
}
