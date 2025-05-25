import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_skripsi/api/api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PromotionScreen(),
    );
  }
}

class PromotionScreen extends StatefulWidget {
  @override
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  List<String> imageUrls = [];
  int currentIndex = 0;
  late Timer _timer;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _pageController = PageController(initialPage: currentIndex);
    // Timer to change image every 1 second
    _timer = Timer.periodic(Duration(seconds: 1), _changeImage);
  }

  // Load image URLs from the assets
  void _loadImages() {
    imageUrls = [
      '${API.BASE_URL}/images/promotion_images/images001.jpg',
      '${API.BASE_URL}/images/promotion_images/images002.jpg',
      '${API.BASE_URL}/images/promotion_images/images003.jpg',
      '${API.BASE_URL}/images/promotion_images/images004.jpg',
      '${API.BASE_URL}/images/promotion_images/images005.jpg',
      '${API.BASE_URL}/images/promotion_images/images006.jpg',
      '${API.BASE_URL}/images/promotion_images/images007.jpg',
      '${API.BASE_URL}/images/promotion_images/images008.jpg',
    ];
  }

  // Function to change the image every second
  void _changeImage(Timer timer) {
    if (imageUrls.isNotEmpty) {
      setState(() {
        currentIndex =
            (currentIndex + 1) % imageUrls.length; // Loop through images
      });
      _pageController.animateToPage(
        currentIndex,
        duration: Duration(
            milliseconds:
                300), // 300ms animation duration for smooth transition
        curve: Curves.easeInOut, // Smooth transition
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Fullscreen carousel
          if (imageUrls.isNotEmpty)
            PageView.builder(
              itemCount: imageUrls.length,
              controller: _pageController,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
        ],
      ),
    );
  }
}
