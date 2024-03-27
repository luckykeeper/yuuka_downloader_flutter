import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

class DownloadPlatformSettingEntryPage extends StatelessWidget {
  const DownloadPlatformSettingEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size scrSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "下载平台设置",
                style: styleFontSimkai,
              ),
              const Expanded(
                child: Text(""),
              )
            ],
          ),
          onPanStart: (details) {
            windowManager.startDragging();
          },
          onDoubleTap: () async {
            bool isMaximized = await windowManager.isMaximized();
            if (!isMaximized) {
              windowManager.maximize();
            } else {
              windowManager.unmaximize();
            }
          },
        ),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const Row(
                children: [
                  Text(
                    "首先选择需要设定的下载平台，设置对应的平台信息",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: "simkai"),
                  )
                ],
              ),
              const Divider(),
              Container(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/yuuka2.jpg",
                    width: scrSize.width / 3.8,
                  )
                ],
              ),
              Container(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "从下面选择要进行设定的下载平台进行设定(当前支持的下载平台[Aria2]):",
                    style: styleFontSimkai,
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context,
                      "/downloadPlatformSettingEntryPage/aria2Settings");
                },
                label: Text(
                  "Aria2",
                  style: styleFontSimkai,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
