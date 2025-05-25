import 'package:flutter/material.dart';
import '../app_export.dart';

// ignore: constant_identifier_names
const num FIGMA_DESIGN_WIDTH = 375;
// ignore: constant_identifier_names
const num FIGMA_DESIGN_HEIGHT = 812;
// ignore: constant_identifier_names
const num FIGMA_DESIGN_STATUS_BAR = 0;

extension ResponsiveExtention on num {
  double get _width => SizeUtils.width;
  double get _height => SizeUtils.height;
  double get h => ((this * _width) / FIGMA_DESIGN_WIDTH).clamp(0.0, _width);
  double get v =>
      (this * _height) /
      (FIGMA_DESIGN_HEIGHT - FIGMA_DESIGN_STATUS_BAR).clamp(0.0, _height);
  double get adaptSize {
    var height = v;
    var width = h;
    return height < width ? height.toDoubleValue() : width.toDoubleValue();
  }

  double get fSize => adaptSize;
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(toStringAsFixed(fractionDigits));
  }

  double isNonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}

enum DeviceType { mobile, tablet, desktop }

typedef ResponsiveBuild = Widget Function(
    BuildContext context, Orientation orientation, DeviceType deviceType);

class Sizer extends StatelessWidget {
  const Sizer({Key? key, required this.builder}) : super(key: key);

  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeUtils.setScreenSize(constraints, orientation);
        return builder(context, orientation, SizeUtils.deviceType);
      });
    });
  }
}

class SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late DeviceType deviceType;
  static late double height;
  static late double width;

  static void setScreenSize(
      BoxConstraints constraints, Orientation currentOrientation) {
    boxConstraints = constraints;
    orientation = currentOrientation;

    if (orientation == Orientation.portrait) {
      width = constraints.maxWidth.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
      height = constraints.maxHeight.isNonZero();
    } else {
      height = constraints.maxWidth.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
      width = constraints.maxHeight.isNonZero();
    }

    // Determine device type based on width and height
    if (width > 600) {
      deviceType = DeviceType.tablet;
    } else if (width > 1200) {
      deviceType = DeviceType.desktop;
    } else {
      deviceType = DeviceType.mobile;
    }
  }
}
