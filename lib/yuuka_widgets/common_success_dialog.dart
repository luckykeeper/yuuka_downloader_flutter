import 'package:flutter/material.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

Future<dynamic> commonSuccessDialog(BuildContext context, String titleText,
    String contentText, String acknowledgeText,
    {Function? interactiveFunction,
    String customImageAssetsLocation =
        "assets/images/operationSuccessYuuka.jpg",
    double customImageWidth = 200}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            titleText,
            style: styleFontSimkai,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) => Image.asset(
                      customImageAssetsLocation,
                      width: customImageWidth,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(contentText, style: styleFontSimkai),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (interactiveFunction == null) {
                    Navigator.of(context).pop();
                  } else {
                    interactiveFunction();
                  }
                },
                child: Text(
                  acknowledgeText,
                  style: styleFontSimkai,
                ))
          ],
        );
      });
}
