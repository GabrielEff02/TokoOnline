import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

//*Controller untuk mengambil foto dari gallery ataupun camera

class ImagePickerController extends GetxController {
  late final Rx<File> _image = Rx<File>(File(''));

  File get image => _image.value;

  Future<void> pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      _image.value = File(pickedImage.path);
      update();
    }
  }
}
