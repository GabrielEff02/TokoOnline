import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../screen/gabriel/core/app_export.dart';
import 'dart:async';

class LandingScreenController extends GetxController {
  var categoryData = <String, dynamic>{}.obs;
  var currentIndex = 0.obs;
  late PageController pageController;
  late Timer _timer;

  // Assuming carouselImages holds your list of images
  var carouselImages = <String>[]; // Replace with actual image list or data

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 1);
    getCategoryData();

    // Start timer to change pages
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      nextPage();
    });
  }

  @override
  void onClose() {
    _timer.cancel();
    pageController.dispose();
    super.onClose();
  }

  Future<void> getCategoryData() async {
    final fetchData = await LandingScreenData.getCategoryData();
    categoryData.value = fetchData;
  }

  void nextPage() {
    if (pageController.hasClients && carouselImages.isNotEmpty) {
      currentIndex.value = (currentIndex.value + 1) % carouselImages.length;
      pageController.animateToPage(
        currentIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final LandingScreenController controller = Get.put(LandingScreenController());
  List<String> carouselImages = [];
  List<String> carouselTitle = [];

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    getCarouselData();
    super.initState();
  }

  Future<void> getCarouselData() async {
    final fetchData = await LandingScreenData.getCarouselData();
    setState(() {
      carouselImages = List<String>.from(
          fetchData.map((item) => item['image_url'] as String));
      carouselTitle =
          List<String>.from(fetchData.map((item) => item['title'] as String));
      controller.carouselImages = carouselImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return carouselImages.length > 0
        ? Obx(
            () {
              // Ensure currentIndex is always in range
              if (controller.currentIndex.value >= carouselImages.length) {
                controller.currentIndex.value =
                    0; // Reset to first index if out of bounds
              }
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(),
                    width: double.infinity,
                    height: 150,
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: carouselImages.length,
                      onPageChanged: (index) =>
                          controller.currentIndex.value = index,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                            imageUrl:
                                "${API.BASE_URL}/img/carousel/${carouselImages[index]}",
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Image.asset(
                                "assets/images/image_not_found.png"),
                            errorWidget: (context, url, error) => Image.asset(
                                "assets/images/image_not_found.png"));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SmoothPageIndicator(
                    controller: controller.pageController,
                    count: carouselImages.length,
                    effect: const WormEffect(
                      dotHeight: 12.0,
                      dotWidth: 12.0,
                      type: WormType.normal,
                      activeDotColor: Colors.blueAccent,
                    ),
                    onDotClicked: (index) {
                      controller.currentIndex.value = index;
                      controller.pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                ],
              );
            },
          )
        : Container();
  }
}
