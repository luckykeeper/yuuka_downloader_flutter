import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/subfunction/launch_url.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

const appVersion = '1.0.0.1Build20240326';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _goodByeYuuka() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "提示",
              style: styleFontSimkai,
            ),
            content: Text("你确定要退出嘛?", style: styleFontSimkai),
            actions: [
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "取消",
                    style: styleFontSimkai,
                  )),
              TextButton(
                  onPressed: () {
                    // https://github.com/flutter/flutter/issues/66631
                    // 以下方法在移动端生效
                    // SystemChannels.platform
                    //     .invokeListMethod('SystemNavigator.pop');
                    exit(0);
                  },
                  child: Text(
                    "确定",
                    style: styleFontSimkai,
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size scrSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: const Row(
            children: [
              Text(
                "Welcome YuukaDownloader",
                style: TextStyle(fontFamily: "NotoSans"),
              ),
              Expanded(
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
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                "下载平台设置",
                style: styleFontSimkai,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                    context, "/downloadPlatformSettingEntryPage");
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_sharp),
              title: Text(
                "下发下载任务",
                style: styleFontSimkai,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/downloadQuestPage");
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_sharp),
              title: Text(
                "历史数据库",
                style: styleFontSimkai,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/historyDatabaseEntryPage");
              },
            ),
            Flexible(
                child: Container(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(
                  "退出",
                  style: styleFontSimkai,
                ),
                onTap: () async {
                  _goodByeYuuka();
                },
              ),
            ))
          ],
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const Row(
                children: [
                  Text(
                    "Welcome YuukaDownloader Flutter Ver. By Luckykeeper",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              Container(
                height: scrSize.height / 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/yuuka.jpg",
                    width: scrSize.width / 3.5,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "↑优香酱可爱捏",
                    style: styleFontSimkai,
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "YuukaDownloader Flutter Ver. $appVersion | Powered By Luckykeeper",
                    style: styleFontSimkai,
                  ),
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await launchUrlWithBrowser(
                                "https://github.com/luckykeeper/YuukaDownloader");
                          } catch (e) {
                            yuukaLogger.e(e);
                            BotToast.showSimpleNotification(
                                duration: const Duration(seconds: 2),
                                hideCloseButton: false,
                                backgroundColor: Colors.pink[300],
                                title: "链接打开失败:$e",
                                titleStyle: styleFontSimkai);
                          }
                        },
                        label: Text(
                          "访问 Golang 版项目",
                          style: styleFontSimkai,
                        ),
                        icon: const FaIcon(FontAwesomeIcons.github),
                      ),
                      Container(
                        width: 20,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await launchUrlWithBrowser(
                                "https://github.com/luckykeeper");
                          } catch (e) {
                            BotToast.showSimpleNotification(
                                duration: const Duration(seconds: 2),
                                hideCloseButton: false,
                                backgroundColor: Colors.pink[300],
                                title: "链接打开失败:$e",
                                titleStyle: styleFontSimkai);
                          }
                        },
                        label: Text(
                          "Github",
                          style: styleFontSimkai,
                        ),
                        icon: const FaIcon(FontAwesomeIcons.github),
                      ),
                      Container(
                        width: 20,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await launchUrlWithBrowser(
                                "https://luckykeeper.site");
                          } catch (e) {
                            BotToast.showSimpleNotification(
                                duration: const Duration(seconds: 2),
                                hideCloseButton: false,
                                backgroundColor: Colors.pink[300],
                                title: "链接打开失败:$e",
                                titleStyle: styleFontSimkai);
                          }
                        },
                        label: Text(
                          "Blog",
                          style: styleFontSimkai,
                        ),
                        icon: const FaIcon(FontAwesomeIcons.blog),
                      )
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
