import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/model/aria2_model.dart';
import 'package:yuuka_downloader_flutter/model/download_link_analyze_result_model.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/download_link_analyze.dart';
import 'package:yuuka_downloader_flutter/subfunction/download_link_list_generator.dart';
import 'package:yuuka_downloader_flutter/subfunction/get_aria2_status.dart';
import 'package:yuuka_downloader_flutter/subfunction/request_aria2_download.dart';
import 'package:yuuka_downloader_flutter/subfunction/save_or_update_info_to_database.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';
import 'package:yuuka_downloader_flutter/yuuka_widgets/common_error_dialog.dart';

class DownloadQuestPage extends StatefulWidget {
  const DownloadQuestPage({super.key});

  @override
  State<DownloadQuestPage> createState() => _DownloadQuestPageState();
}

class _DownloadQuestPageState extends State<DownloadQuestPage> {
  bool _aria2Selected = true;
  bool _ifAria2SettedBool = false;
  String _ifAria2Setted = "N/A";
  TextStyle _ifAria2SettedStyle = const TextStyle(
    fontFamily: "simkai",
  );
  String _ifAria2Connected = "N/A";
  TextStyle _ifAria2ConnectedStyle = const TextStyle(
    fontFamily: "simkai",
  );
  String _downloadSpeed = "N/A";
  String _uploadSpeed = "N/A";
  String _activeTask = "N/A";
  String _stoppedTask = "N/A";
  String _stoppedTaskTotal = "N/A";
  String _queueTask = "N/A";

  final TextEditingController _downloadLink = TextEditingController();
  final TextEditingController _manualPrefix = TextEditingController();

  Timer? _aria2AutoUpdateTimer;
  YuukaDownPlatform aria2Settings = YuukaDownPlatform(ObjectId(), "");

  String _downloadTitleSelected = "";
  final TextEditingController _downloadTitlManually = TextEditingController();

  List<String> _downloadLinkList = [];

  @override
  void initState() {
    super.initState();
    yuukaLogger.i("检查 Aria2 参数是否已经设置...");
    var hayaseYuukaDataEngineConfig = Configuration.local(
        [YuukaDownPlatform.schema],
        path: "./yuukaDownloader.realm");
    var hayaseYuukaDataEngine = Realm(hayaseYuukaDataEngineConfig);
    try {
      final existYuukaInfo = hayaseYuukaDataEngine
          .query<YuukaDownPlatform>("downloaderPlatform == \$0", ["Aria2"]);
      if (existYuukaInfo.isEmpty) {
        if (mounted) {
          setState(() {
            _ifAria2SettedBool = false;
            _ifAria2Setted = "未配置";
            _ifAria2SettedStyle =
                const TextStyle(fontFamily: "simkai", color: Colors.pinkAccent);
            _ifAria2ConnectedStyle =
                const TextStyle(fontFamily: "simkai", color: Colors.pinkAccent);
          });
        }
      } else {
        for (var info in existYuukaInfo) {
          if (info.downloaderPlatform == "Aria2") {
            yuukaLogger.i("Aria2 参数已经配置");
            aria2Settings.platformUrl = info.platformUrl.toString();
            aria2Settings.jsonRPCVer = info.jsonRPCVer.toString();
            aria2Settings.ariaToken = info.ariaToken.toString();
            // yuukaLogger.i("aria2Settings.platformUrl:${aria2Settings.platformUrl}");
            if (mounted) {
              setState(() {
                _ifAria2SettedBool = true;
                _ifAria2Setted = "已配置";
                _ifAria2SettedStyle = const TextStyle(
                    fontFamily: "simkai", color: Colors.greenAccent);
                _ifAria2ConnectedStyle = const TextStyle(
                    fontFamily: "simkai", color: Colors.yellowAccent);
              });
            }
          }
        }
      }
      if (_ifAria2SettedBool) {
        // yuukaLogger.i("定时器: _aria2AutoUpdateTimer 启动!");
        // yuukaLogger.i("aria2Settings.platformUrl:${aria2Settings.platformUrl}");
        _aria2AutoUpdateTimer =
            Timer.periodic(const Duration(seconds: 1), (timer) async {
          // yuukaLogger.i("定时器: _aria2AutoUpdateTimer 执行一次!");
          try {
            List result = await getAria2Status(aria2Settings);
            int statusCode = 0;
            bool requestStatus = false;
            Aria2RequestReturn? serverResponse;
            statusCode = result[0];
            if (result[1].toString().isNotEmpty) {
              serverResponse = result[1];
              requestStatus = true;
            } else {
              requestStatus = false;
            }

            if (!requestStatus) {
              if (mounted) {
                setState(() {
                  _ifAria2Connected = "未连接";
                  _ifAria2ConnectedStyle = const TextStyle(
                      fontFamily: "simkai", color: Colors.pinkAccent);
                  _downloadSpeed = "N/A";
                  _uploadSpeed = "N/A";
                  _activeTask = "N/A";
                  _stoppedTask = "N/A";
                  _stoppedTaskTotal = "N/A";
                  _queueTask = "N/A";
                });
              }
            } else {
              if (statusCode == 200) {
                // yuukaLogger.i("获取 Aria2 服务器信息成功");
                if (mounted) {
                  setState(() {
                    _ifAria2Connected = "连接成功";
                    _ifAria2ConnectedStyle = const TextStyle(
                        fontFamily: "simkai", color: Colors.greenAccent);
                    _downloadSpeed = serverResponse!.result!.downloadSpeed!;
                    _uploadSpeed = serverResponse.result!.uploadSpeed!;
                    _activeTask = serverResponse.result!.numActive!;
                    _stoppedTask = serverResponse.result!.numStopped!;
                    _stoppedTaskTotal = serverResponse.result!.numStoppedTotal!;
                    _queueTask = serverResponse.result!.numWaiting!;
                  });
                }
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _ifAria2Connected = "无法连接，网络问题或连接参数错误";
                _ifAria2ConnectedStyle = const TextStyle(
                    fontFamily: "simkai", color: Colors.pinkAccent);
                _downloadSpeed = "N/A";
                _uploadSpeed = "N/A";
                _activeTask = "N/A";
                _stoppedTask = "N/A";
                _stoppedTaskTotal = "N/A";
                _queueTask = "N/A";
              });
            }
          }
        });
      } else {
        yuukaLogger.i("没有设置 Aria2 平台参数，定时器: _aria2AutoUpdateTimer 不启动!");
      }
    } catch (e) {
      yuukaLogger.e(e.toString());
    } finally {
      hayaseYuukaDataEngine.close();
    }
  }

  @override
  void dispose() {
    if (!(_aria2AutoUpdateTimer == null) && (_aria2AutoUpdateTimer!.isActive)) {
      _aria2AutoUpdateTimer!.cancel();
      yuukaLogger.i("定时器: _aria2AutoUpdateTimer 已停止!");
    } else {
      yuukaLogger.i("没有启动定时器: _aria2AutoUpdateTimer 无需停止!");
    }
    super.dispose();
  }

  _readClipBoard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) {
      if (mounted) {
        return commonErrorDialog(context, "寄啦", "剪贴板没有数据，或剪贴板内的数据不是文本", "我知道了");
      }
      // }
      // return showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         title: Text(
      //           "寄啦",
      //           style: styleFontSimkai,
      //         ),
      //         content: Text("剪贴板没有数据，或剪贴板内的数据不是文本", style: styleFontSimkai),
      //         actions: [
      //           TextButton(
      //               onPressed: Navigator.of(context).pop,
      //               child: Text(
      //                 "我知道了",
      //                 style: styleFontSimkai,
      //               ))
      //         ],
      //       );
      //     });
    } else {
      if (mounted) {
        setState(() {
          _downloadLink.text = data.text!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size scrSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "下发下载任务",
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
                    "下发下载任务到选定的平台q(≧▽≦q)",
                    style: TextStyle(
                        fontFamily: "simkai",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              Container(
                height: 50,
              ),
              Image.asset(
                "assets/images/downloadQuest.jpg",
                width: scrSize.width / 3,
              ),
              Row(
                children: [
                  Text(
                    "\t\t\t\t\t选择下载平台:",
                    style: styleFontSimkai,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 30,
                  ),
                  Checkbox(
                      value: _aria2Selected,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            // 暂时只能选择 Aria2
                            // _aria2Selected = value!;
                            _aria2Selected = true;
                          });
                        }
                      }),
                  Text(
                    "\tAria2",
                    style: styleFontSimkai,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("        "),
                  Text(
                    "下载任务链接:\t\t",
                    style: styleFontSimkai,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _downloadLink,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return value!.trim().isNotEmpty ? null : "下载链接不能为空";
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.link),
                        label: const Text(
                            "在这里输入初音站的下载链接(多part压缩包输入最后一part链接，可以自动分析)，或者使用右边的粘贴按钮"),
                        labelStyle: styleFontSimkai,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        _readClipBoard();
                      },
                      icon: const Icon(Icons.paste)),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (_downloadLink.text.isNotEmpty) {
                          var result = await downloadLinkAnalyze(
                              _downloadLink.text, null);
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "解析",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 40,
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              Row(
                children: [
                  const Text("        "),
                  Text(
                    "切换下载站👉",
                    style: styleFontSimkai,
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (_downloadLink.text.isNotEmpty) {
                          var result =
                              await downloadLinkAnalyze(_downloadLink.text, "");
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "@",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 20,
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (_downloadLink.text.isNotEmpty) {
                          var result = await downloadLinkAnalyze(
                              _downloadLink.text, "zz");
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "zz",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 20,
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (_downloadLink.text.isNotEmpty) {
                          var result = await downloadLinkAnalyze(
                              _downloadLink.text, "qq");
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "qq",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 20,
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (_downloadLink.text.isNotEmpty) {
                          var result = await downloadLinkAnalyze(
                              _downloadLink.text, "gs");
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "gs",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("        "),
                  Text(
                    "手动输入前缀进行解析:\t\t",
                    style: styleFontSimkai,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _manualPrefix,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // validator: (value) {
                      //   return value!.trim().isNotEmpty ? null : "手动解析前缀不能为空";
                      // },
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.link),
                          label: Text(
                              "在这里输入手动解析前缀，例如：https://qq.llgal.xyz 的前缀为 qq"),
                          labelStyle: TextStyle(
                              fontFamily: "simkai",
                              // fontSize: 10,
                              overflow: TextOverflow.fade)),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if ((_downloadLink.text.isNotEmpty) &&
                            (_manualPrefix.text.isNotEmpty)) {
                          var result = await downloadLinkAnalyze(
                              _downloadLink.text, _manualPrefix.text);
                          if (result.analyzeResultBool) {
                            if (context.mounted) {
                              return await downloadQuestAria2Dialog(
                                  context, result);
                            }
                          } else {
                            if (context.mounted) {
                              return commonErrorDialog(context, "寄啦",
                                  result.analysisResult["errMsg"]!, "我知道了");
                            }
                          }
                        } else {
                          return commonErrorDialog(
                              context, "寄啦", "输入的链接是空的，或者手动解析前缀是空的？！", "我知道了");
                        }
                      },
                      label: Text(
                        "手动解析",
                        style: styleFontSimkai,
                      ),
                      icon: const Icon(Icons.ads_click)),
                  Container(
                    width: 40,
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              Builder(
                builder: (context) {
                  if (_aria2Selected) {
                    return Row(
                      children: [
                        const Text("        "),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Aria2 平台参数设置情况:",
                                style: TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.greenAccent),
                              ),
                              Text(
                                "下载速度(m/s):",
                                style: styleFontSimkai,
                              ),
                              Text(
                                "活跃任务:",
                                style: styleFontSimkai,
                              ),
                              Text(
                                "已停止任务:",
                                style: styleFontSimkai,
                              ),
                            ]),
                        Container(
                          width: 20,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ifAria2Setted,
                                style: _ifAria2SettedStyle,
                              ),
                              Text(
                                _downloadSpeed,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                _activeTask,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                _stoppedTask,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                            ]),
                        Container(
                          width: 200,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Aria2 平台连接情况:",
                                style: TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.greenAccent),
                              ),
                              Text(
                                "上传速度(m/s):",
                                style: styleFontSimkai,
                              ),
                              Text(
                                "队列任务:",
                                style: styleFontSimkai,
                              ),
                              Text(
                                "已停止任务总数:",
                                style: styleFontSimkai,
                              ),
                            ]),
                        Container(
                          width: 20,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ifAria2Connected,
                                style: _ifAria2ConnectedStyle,
                              ),
                              Text(
                                _uploadSpeed,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                _queueTask,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                              Text(
                                _stoppedTaskTotal,
                                style: const TextStyle(
                                    fontFamily: "simkai",
                                    color: Colors.blueAccent),
                              ),
                            ]),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Future<dynamic> downloadQuestAria2Dialog(
      BuildContext context, DownloadLinkAnalyzeResult downloadInfo) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Text(
                  "下发下载任务 - Aria2",
                  style: styleFontSimkai,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Row(
                      children: [
                        Text(
                          "解析成功！请填写下载信息并发送平台，或点击下方取消或屏幕空白区域取消下载",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "选择保存到数据库的标题:",
                          style: styleFontSimkai,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            List<DropdownMenuEntry<String>> buildMenuList(
                                List<String> data) {
                              return data.map((String value) {
                                return DropdownMenuEntry<String>(
                                  value: value,
                                  label: value,
                                );
                              }).toList();
                            }

                            onSelect(String? value) {
                              try {
                                setState(() {
                                  _downloadTitleSelected = value!;
                                });
                                yuukaLogger.i("当前选择标题:$_downloadTitleSelected");
                              } catch (e) {
                                setState(() {
                                  _downloadTitleSelected =
                                      _downloadTitlManually.text;
                                });
                                yuukaLogger.i("手动输入标题:$_downloadTitleSelected");
                              }
                            }

                            List<String> data = downloadInfo.gameNameOptions;
                            _downloadTitleSelected = data.last;
                            yuukaLogger.i("默认选择标题:$_downloadTitleSelected");
                            return DropdownMenu<String>(
                              textStyle: styleFontSimkai,
                              controller: _downloadTitlManually,
                              initialSelection: data.last,
                              onSelected: onSelect,
                              dropdownMenuEntries: buildMenuList(data),
                              leadingIcon: const Icon(Icons.title_rounded),
                              trailingIcon: const Icon(Icons.search),
                              inputDecorationTheme: const InputDecorationTheme(
                                filled: true,
                                labelStyle: TextStyle(fontFamily: "simkai"),
                                helperStyle: TextStyle(fontFamily: "simkai"),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 5.0),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          "链接解析结果:",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "文件夹名称: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                        Text(
                          downloadInfo.gameNameOptions[
                              downloadInfo.gameNameOptions.length - 2],
                          style: styleFontSimkai,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "文件名称: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                        Text(
                          downloadInfo.gameNameOptions.last,
                          style: styleFontSimkai,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "下载线路: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                        Builder(builder: (context) {
                          if (downloadInfo.analysisResult["prefix"]!.isEmpty) {
                            return Text(
                              "@",
                              style: styleFontSimkai,
                            );
                          }
                          return Text(
                            downloadInfo.analysisResult["prefix"]!,
                            style: styleFontSimkai,
                          );
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "分区: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                        Text(
                          downloadInfo.analysisResult["subArea"]!,
                          style: styleFontSimkai,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "part数量: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                        Text(
                          downloadInfo.analysisResult["partNum"]!,
                          style: styleFontSimkai,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("文件后缀: ",
                            style: TextStyle(
                                fontFamily: "simkai",
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan[200])),
                        Text(downloadInfo.analysisResult["fileType"]!,
                            style: styleFontSimkai),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "下载任务预览: ",
                          style: TextStyle(
                              fontFamily: "simkai",
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[200]),
                        ),
                      ],
                    ),
                    Builder(builder: (context) {
                      Widget downloadQuestPreview(String url, int sequence) {
                        return Row(
                          children: [
                            Text(
                              (sequence + 1).toString(),
                              style: TextStyle(
                                  fontFamily: "simkai",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.cyan[200]),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                url,
                                style: styleFontSimkai,
                                // overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        );
                      }

                      List<Widget> downloadQuestPreviewWidgets = [];
                      _downloadLinkList = [];
                      _downloadLinkList =
                          downloadLinkListGenerator(downloadInfo);
                      for (var i = 0; i < _downloadLinkList.length; i++) {
                        downloadQuestPreviewWidgets
                            .add(downloadQuestPreview(_downloadLinkList[i], i));
                      }
                      return Column(
                        children: downloadQuestPreviewWidgets,
                      );
                    })
                  ]),
            ),
            actions: [
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "取消下载",
                    style: styleFontSimkai,
                  )),
              TextButton(
                  onPressed: () async {
                    var notificationCancel = BotToast.showSimpleNotification(
                        duration: Duration(
                            seconds: downloadInfo.gameNameOptions.length * 2),
                        hideCloseButton: false,
                        backgroundColor: Colors.green[300],
                        title: "任务请求下发中，请耐心等候……",
                        titleStyle: styleFontSimkai);
                    if (_ifAria2SettedBool) {
                      var thisResult = await requestAria2Download(
                          _downloadLinkList, aria2Settings);
                      if (thisResult.isAllSuccessed) {
                        saveOrUpdateInfoToDatabase(
                            downloadInfo, _downloadTitleSelected);
                        notificationCancel();
                        if (context.mounted) {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "下发下载任务成功",
                                    style: styleFontSimkai,
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "assets/images/aria2DownloadQuestSuccess.jpg",
                                                  width: 150,
                                                ),
                                              ],
                                            ),
                                            const Row(
                                              children: [
                                                Text("所有任务下发成功!",
                                                    style: TextStyle(
                                                        fontFamily: "simkai",
                                                        color: Colors
                                                            .greenAccent)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "成功下发任务总计:${thisResult.successCount}",
                                                  style: styleFontSimkai,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName(
                                                  "/downloadQuestPage"));
                                        },
                                        child: Text(
                                          "好耶~",
                                          style: styleFontSimkai,
                                        ))
                                  ],
                                );
                              });
                        }
                      } else {
                        notificationCancel();
                        if (context.mounted) {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "下发下载任务失败",
                                    style: styleFontSimkai,
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Text("存在下载异常的任务",
                                                style: TextStyle(
                                                    fontFamily: "simkai",
                                                    color: Colors.pinkAccent)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "下发成功任务总计:${thisResult.successCount}",
                                              style: styleFontSimkai,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "下发失败任务总计:${thisResult.failureCount}",
                                              style: styleFontSimkai,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "异常详细信息:",
                                              style: styleFontSimkai,
                                            ),
                                          ],
                                        ),
                                        Builder(builder: (context) {
                                          List<Widget> errMsgList = [];
                                          for (var i = 0;
                                              i < thisResult.errMsgs.length;
                                              i++) {
                                            var thisErrMsgRow = Row(
                                              children: [
                                                Text(
                                                  (i + 1).toString(),
                                                  style: TextStyle(
                                                      fontFamily: "simkai",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.cyan[200]),
                                                ),
                                                const VerticalDivider(),
                                                Expanded(
                                                  child: Text(
                                                    thisResult.errMsgs[i],
                                                    style: styleFontSimkai,
                                                  ),
                                                ),
                                              ],
                                            );
                                            errMsgList.add(thisErrMsgRow);
                                          }
                                          return Column(
                                            children: errMsgList,
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName(
                                                  "/downloadQuestPage"));
                                        },
                                        child: Text(
                                          "啊这！",
                                          style: styleFontSimkai,
                                        ))
                                  ],
                                );
                              });
                        }
                      }
                    } else {
                      return commonErrorDialog(
                          context, "你就是阿露！", "不先去设置下载平台参数怎么下载！", "我是阿露");
                    }
                  },
                  child: Text(
                    "下发下载任务",
                    style: styleFontSimkai,
                  ))
            ],
          );
        });
  }
}
