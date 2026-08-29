import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/custom_font.dart';

// ignore: must_be_immutable
class CustomInkwellButton extends StatelessWidget {
  CustomInkwellButton({
    super.key,
    required this.onTap,
    required this.height,
    required this.width,
    this.buttonName = "",
    this.bgColor = FB_DARK_PRIMARY,
    this.fontColor = Colors.white,
    this.fontSize = 16,
    this.icon = const Icon(Icons.circle, color: Colors.transparent),
    this.fontWeight = FontWeight.normal,
  });

  final VoidCallback onTap;
  final double height;
  final double width;
  final double fontSize;
  final String buttonName;
  final Icon icon;

  FontWeight fontWeight;
  Color bgColor;
  Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: bgColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: FB_SECONDARY,
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Center(
            child: buttonName.isEmpty
                ? icon
                : CustomFont(
              text: buttonName,
              fontSize: fontSize,
              color: fontColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}