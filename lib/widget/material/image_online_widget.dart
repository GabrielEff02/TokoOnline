import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageOnlineWidget extends StatelessWidget {
  String? url;
  double? height;
  double? width;
  ImageOnlineWidget({Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      // errorWidget: (context, url, error)=>Image.asset(ImageConstant.placeHolderElsimil),
      fit: BoxFit.fill,
    );
  }
}
