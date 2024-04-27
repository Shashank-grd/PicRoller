import 'dart:io';
import 'package:facesearch/Sliding/photoSliding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Firebase/photoupload.dart';
import 'alertbar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid ? await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDH62d5VX1WzjT2fSGvQgWOEHP5pVzhqbo",
        appId: "1:1001570068151:android:642e08df62f71979918f32",
        messagingSenderId: "1001570068151",
        projectId: "facesearch-bef47",
        storageBucket: "facesearch-bef47.appspot.com",
      )) : await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceSearch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor:const Color.fromRGBO(0, 0, 0, 1),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(30, 30, 30, 1),
        ),
      ),
      home: const MyHomePage(title: 'FaceSearch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List ? _file;
  bool _isLoading =false;

  void postImage() async{
    setState(() {
      _isLoading= true;
    });
    try{
      String res= await FirestoreMethods().uploadPhoto(_file!);

      if(res == 'success') {
        setState(() {
          _isLoading= false;
        });
        clearImage();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SlidingPhoto()),
        );
      }else{
        setState(() {
          _isLoading= false;
        });
        showSnackBar(res, context);
      }
    }catch(e){
      showSnackBar(e.toString(), context);
    }
  }
  void clearImage(){
    setState(() {
      _file=null;
    });
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile ? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    }

    print("NO image selected");
  }

  _selectImage(BuildContext context) async{
    return showDialog(context: context, builder: (context){
      return SimpleDialog(
        title: const Text("Choose a Image"),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child:  const Text("Take a Photo"),
            onPressed: () async{
              Navigator.of(context).pop();
              Uint8List file =await pickImage(ImageSource.camera);
              setState(() {
                _file =file;
                postImage();
              });
            },
          ), SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child:  const Text("Choose from Gallery"),
            onPressed: () async{
              Navigator.of(context).pop();
              Uint8List file =await pickImage(ImageSource.gallery);
              setState(() {
                _file =file;
                postImage();
              });
            },
          ),SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child:  const Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );

    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Center(child: Text(widget.title,style:const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
        ),)),
      ),


      body:_isLoading
          ? Stack(
        children: [
          LinearProgressIndicator(),
          Center(
            child: Image.asset(
              'assets/systemic.gif',
              width: 200, // adjust the width and height to your liking
              height: 200,
            ),
          ),
        ],
      )
          : Center(
        child: IconButton(
          onPressed: () {
            _selectImage(context);
          },
          icon: const Icon(Icons.upload,size: 50,),
        ),
      ),

    );
  }
}

