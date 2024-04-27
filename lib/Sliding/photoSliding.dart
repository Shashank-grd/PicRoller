import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SlidingPhoto extends StatefulWidget{
  const SlidingPhoto({Key ? key}) : super (key: key);
  @override
  _SlidingPhotoState createState() => _SlidingPhotoState();
}
class _SlidingPhotoState extends State<SlidingPhoto>{
  late Stream<QuerySnapshot> imageStream;
  int currentSlideIndex = 0;
  final CarouselController carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    var firebase = FirebaseFirestore.instance;
    imageStream = firebase.collection("photos").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          SizedBox(
            height: 500,
            width: double.infinity,
            child: StreamBuilder<QuerySnapshot>(
              stream: imageStream,
              builder: (_, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                  return CarouselSlider.builder(
                      carouselController: carouselController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, index, ___) {
                        DocumentSnapshot sliderImage =
                        snapshot.data!.docs[index];
                        return Image.network(
                          sliderImage['photoUrl'],
                          fit: BoxFit.contain,
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        onPageChanged: (index, _) {
                          setState(() {
                            currentSlideIndex = index;
                          });
                        },
                        autoPlayInterval: Duration(seconds: 2), // Switch slides every 2 seconds
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            ' Current Slide Index $currentSlideIndex',
            style: const TextStyle(fontSize: 25),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => carouselController.previousPage(),
                icon: Icon(Icons.arrow_left,size: 50,),
              ),
              IconButton(
                onPressed: () => carouselController.nextPage(),
                icon: Icon(Icons.arrow_right,size: 50,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}