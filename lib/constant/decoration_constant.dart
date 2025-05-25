import 'package:flutter/material.dart';
import 'text_constant.dart';

class DecorationConstant {
  static boxCard() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            offset: Offset(1, 1),
          )
        ]);
  }

  static boxImage({required String src, BoxFit fit = BoxFit.cover}) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(src),
        fit: BoxFit.cover,
      ),
    );
  }

  static boxRadiusOnly({
    double topLeft = 0,
    double bottomLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    Color color = Colors.transparent,
  }) {
    return BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            bottomLeft: Radius.circular(bottomLeft),
            topRight: Radius.circular(topRight),
            bottomRight: Radius.circular(bottomRight)),
        color: color);
  }

  static boxRadiusShadowOnly({
    double topLeft = 0,
    double bottomLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    Color color = Colors.transparent,
    Color? colorShadow,
    double? spreadRadius,
    double? blurRadius,
    Offset? offset,
  }) {
    return BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            bottomLeft: Radius.circular(bottomLeft),
            topRight: Radius.circular(topRight),
            bottomRight: Radius.circular(bottomRight)),
        boxShadow: [
          BoxShadow(
            color: colorShadow!,
            spreadRadius: spreadRadius!,
            blurRadius: blurRadius!,
            offset: offset!,
          ),
        ],
        color: color);
  }

  static boxCircle({
    Color color = Colors.transparent,
  }) {
    return BoxDecoration(shape: BoxShape.circle, color: color);
  }

  static boxCircleBorder(
      {Color color = Colors.transparent,
      Color colorBorder = Colors.transparent,
      double widthBorder = 0}) {
    return BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: colorBorder, width: widthBorder));
  }

  static boxButton({
    double radius = 0,
    Color color = Colors.transparent,
  }) {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)), color: color);
  }

  static boxButtonBorder(
      {double radius = 0,
      Color color = Colors.transparent,
      Color colorBorder = Colors.transparent,
      double widthBorder = 0}) {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        color: color,
        border: Border.all(color: colorBorder, width: widthBorder));
  }

  static boxShadowButon({
    double? radius,
    Color? color,
    Color? colorShadow,
    double? spreadRadius,
    double? blurRadius,
    Offset? offset,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius!)),
      color: color,
      boxShadow: [
        BoxShadow(
          color: colorShadow!,
          spreadRadius: spreadRadius!,
          blurRadius: blurRadius!,
          offset: offset!,
        ),
      ],
    );
  }

  static boxShadowButtonBorder({
    double radius = 0,
    Color color = Colors.transparent,
    Color colorBorder = Colors.transparent,
    double widthBorder = 0,
    Color colorShadow = Colors.transparent,
    double spreadRadius = 0,
    double blurRadius = 0,
    Offset? offset,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      color: color,
      border: Border.all(color: colorBorder, width: widthBorder),
      boxShadow: [
        BoxShadow(
          color: colorShadow,
          spreadRadius: spreadRadius,
          blurRadius: blurRadius,
          offset: offset ?? Offset(0, 0),
        ),
      ],
    );
  }

  static InputDecoration inputDecor() {
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      hintStyle: TextConstant.regular
          .copyWith(fontSize: 13, color: Colors.grey.shade400),
    );
  }
}
