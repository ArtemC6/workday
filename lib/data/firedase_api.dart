import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String description, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(description);
      return ref.putFile(file);
    } on FirebaseException catch (_) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destinaiton, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destinaiton);
      return ref.putData(data);
    } on FirebaseException catch (_) {
      return null;
    }
  }
}
