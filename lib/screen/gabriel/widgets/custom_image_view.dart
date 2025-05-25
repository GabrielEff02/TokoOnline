import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_export.dart';

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }

// ignore: must_be_immutable
class CustomImageView extends StatelessWidget {
  CustomImageView({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.alignment,
    this.border,
    this.color,
    this.fit,
    this.margin,
    this.onTap,
    this.radius,
  });
  String? imagePath;
  double? height;
  double? width;
  Color? color;
  BoxFit? fit;
  final String placeHolder = "assets/images/image_not_found.png";
  Alignment? alignment;
  VoidCallback? onTap;
  EdgeInsetsGeometry? margin;
  BorderRadius? radius;
  BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: _buildCircleImage(),
          ),
        ));
  }

  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: _buildImageWithBorder());
    }
    return _buildImageWithBorder();
  }

  _buildImageWithBorder() {
    if (border != null) {
      return Container(
          decoration: BoxDecoration(border: border, borderRadius: radius),
          child: _buildImageView());
    }
    return _buildImageView();
  }

  _buildImageView() {
    if (imagePath != null) {
      switch (imagePath!.imageType) {
        case ImageType.svg:
          return SizedBox(
              height: height,
              width: width,
              child: SvgPicture.asset(imagePath!,
                  height: height,
                  width: width,
                  fit: fit ?? BoxFit.contain,
                  colorFilter: color != null
                      ? ColorFilter.mode(
                          color ?? Colors.transparent, BlendMode.srcIn)
                      : null));
        case ImageType.png:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: imagePath!,
            color: color,
            placeholder: (context, url) => Image.asset(placeHolder,
                height: height, width: width, fit: fit ?? BoxFit.fill),
            errorWidget: (context, url, error) => Image.asset(placeHolder,
                height: height,
                width: width,
                fit: fit ?? BoxFit.fill,
                color: color),
          );
        case ImageType.file:
          return Image.file(File(imagePath!),
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color);
        case ImageType.unknown:
          return const SizedBox();
      }
    }
  }
}
