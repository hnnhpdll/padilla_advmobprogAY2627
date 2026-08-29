import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padilla_mobprog/widgets/custom_font.dart';

class CustomButton extends StatefulWidget {
  final String buttonType;
  final String buttonName;
  final Color fontColor;
  final Color outlineColor;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    this.buttonType = 'elevated',
    required this.buttonName,
    required this.onPressed,
    this.fontColor = Colors.black,
    this.outlineColor = Colors.black,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final String type = widget.buttonType.toLowerCase();

    if (type == 'outlined') {
      return OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide(color: widget.outlineColor),
        ),
        child: CustomFont(
          text: widget.buttonName,
          fontSize: ScreenUtil().setSp(12),
          color: widget.fontColor,
        ),
      );
    }
    if (type == 'text') {
      return TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: CustomFont(
          text: widget.buttonName,
          fontSize: ScreenUtil().setSp(12),
          color: widget.fontColor,
        ),
      );
    }

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setHeight(10),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: CustomFont(
        text: widget.buttonName,
        fontSize: ScreenUtil().setSp(12),
        color: widget.fontColor,
      ),
    );
  }
}
