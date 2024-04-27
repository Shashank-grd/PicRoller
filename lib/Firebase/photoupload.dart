import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';


class StorageMethods{
  final FirebaseStorage _storage=FirebaseStorage.instance;
  String id= const Uuid().v1();
  Future<String> uploadImageToStorage(String childName,Uint8List file) async{
    Reference ref= _storage.ref().child(childName).child(id);

    UploadTask uploadTask=ref.putData(file);
    TaskSnapshot snap= await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;

  }
}

class User{
  final String photoUrl;
  final String uid;

  const User({
    required this.photoUrl,
    required this.uid,
  });

  Map<String ,dynamic> toJson() =>{
    "uid":uid,
    "photoUrl": photoUrl,

  };
  static User fromsnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String ,dynamic>;
    return User(uid: snapshot['uid'],photoUrl: snapshot['photoUrl'],);
  }
}

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future <String > uploadPhoto(
      Uint8List file,
      ) async{
    String res="some error occcured";
    try{
      String photoUrl=await StorageMethods().uploadImageToStorage("photos",file);
      String postId=const Uuid().v1();
      User user=User(photoUrl: photoUrl, uid: postId);

      _firestore.collection('photos').doc(postId).set(user.toJson(),);
      res="success";
    }catch(err){
      res=err.toString();
    }
    return res;
  }
}