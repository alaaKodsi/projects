import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';


Future<File?> openCamera(BuildContext context) async {
  try {
    Navigator.of(context).pop();
    XFile? image = await ImagePicker()//lib to open camera
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image?.path != null && image!.path.isNotEmpty) {
      File imageFile = File(image.path);
      final length = await imageFile.length();
      if (length < 7000000) {
        return imageFile;
      } else {
        BotToast.showText(text: 'Photo is too large!');
      }
    }
  } on PlatformException {
    BotToast.showText(text: 'Couldn\'t get permission to open camera!');
  } catch (e) {
    print('----- openCamera => ERROR = $e');
    BotToast.showText(text: 'Failed to open camera!');
  }
  return null;
}

Future<File?> openGallery(BuildContext context) async {
  try {
    Navigator.of(context).pop();
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image?.path != null && image!.path.isNotEmpty) {
      File imageFile = File(image.path);
      final length = await imageFile.length();
      if (length < 7000000) {
        return imageFile;
      } else {
        BotToast.showText(text: 'Photo is too large!');
      }
    }
  } on PlatformException {
    BotToast.showText(text: 'Couldn\'t get permission to access gallery files!');
  } catch (e) {
    print('----- openCamera => ERROR = $e');
    BotToast.showText(text: 'Failed to access gallery files!');
  }
}

extension UploadFileExtension on File? {

  Future<MultipartFile?> get toMultiPart {
    if (this == null) return Future.value(null);
    return MultipartFile.fromFile(
      this!.path,
      filename: this.fileName,
      contentType: MediaType(this.fileType, this.extension),
    );
  }

  String get extension {
    return this!.path.substring(this!.path.lastIndexOf('.') + 1).toLowerCase();
  }

  /// Return generated file name
  String get fileName {
    String name = DateTime.now().toIso8601String().substring(0, 19);
    name = name.replaceAll(':', '').replaceAll('-', '').replaceAll('.', '');
    name += '.${this.extension}';
    return name;
  }

  /// Return the MIME type of the file
  String get fileType {
    switch (this.extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'image';
      case 'pdf':
        return 'application';
      default:
        return '';
    }
  }

  /// Return true if the file extension is supported by the app
  bool get isSupported => SUPPORTED_EXTENSIONS.contains(this.extension);

  /// Return true if the file size is less than 10 MB, which is
  /// the maximum size accepted by the back-end
  bool get isAccepted => this!.lengthSync() < 10 * 1024 * 1024;

  bool get isNotNull => this != null;

}

const SUPPORTED_EXTENSIONS = [
  'png',
  'jpg',
  'jpeg',
];
