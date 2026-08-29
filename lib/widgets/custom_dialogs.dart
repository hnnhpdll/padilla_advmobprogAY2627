import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import 'custom_font.dart';

void customDialog(
    BuildContext context, {
      required String title,
      required String content,
      required Function onYes,
    }) {
  AlertDialog alertDialog = AlertDialog(
    title: CustomFont(
      text: title,
      fontSize: 30.sp,
      color: Colors.black,
    ),
    content: CustomFont(
      text: content,
      fontSize: 16.sp,
      color: Colors.black,
    ),
    actions: <Widget>[
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: CustomFont(
          text: "Cancel",
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onYes();
        },
        child: CustomFont(
          text: "Okay",
          fontSize: 16.sp,
          color: FB_TEXT_COLOR_WHITE,
        ),
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

void customShowImageDialog(
    BuildContext context, {
      required String imageUrl,
    }) {
  AlertDialog alertDialog = AlertDialog(
    contentPadding: const EdgeInsets.all(16),
    content: Stack(
      children: [
        SizedBox(
          height: 300.h,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(
                    color: FB_DARK_PRIMARY,
                    value: downloadProgress.progress,
                  ),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                size: 100.sp,
              ),
            ),
          ),
        ),

        // X Button
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}