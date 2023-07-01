import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = FirebaseStorage.instance.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveData({
    required Uint8List file,
  }) async {
    String resp = " Some Error Occurred";
    try {
      User user = FirebaseAuth.instance.currentUser!;
      String imageUrl = await uploadImageToStorage(user.uid, file);
      await user.updatePhotoURL(
        imageUrl,
      );
      resp = 'Success';
    } catch (err) {
      resp = err.toString();
    }
    print(resp);
  }
}
