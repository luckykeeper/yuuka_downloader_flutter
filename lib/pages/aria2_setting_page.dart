import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/model/aria2_model.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/get_aria2_status.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';
import 'package:yuuka_downloader_flutter/yuuka_widgets/common_error_dialog.dart';
import 'package:yuuka_downloader_flutter/yuuka_widgets/common_success_dialog.dart';

class Aria2SettingPage extends StatefulWidget {
  const Aria2SettingPage({super.key});

  @override
  State<Aria2SettingPage> createState() => _Aria2SettingPageState();
}

class _Aria2SettingPageState extends State<Aria2SettingPage> {
  final TextEditingController _aria2PlatformAddress = TextEditingController();

  final TextEditingController _aria2RPCVer = TextEditingController();

  final TextEditingController _aria2Password = TextEditingController();

  String _aria2SettingedStatus = "";

  TextStyle _aria2SettingedTextStyle =
      TextStyle(fontFamily: "simkai", color: Colors.yellow[300]);

  @override
  void initState() {
    super.initState();
    yuukaLogger.i("Aria2 Settins Page initState!");
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
            _aria2SettingedStatus = "未设置";
            _aria2SettingedTextStyle =
                TextStyle(fontFamily: "simkai", color: Colors.yellow[300]);
          });
        }
      } else {
        for (var info in existYuukaInfo) {
          if (info.downloaderPlatform == "Aria2") {
            if (mounted) {
              setState(() {
                _aria2SettingedStatus = "已设置";
                _aria2SettingedTextStyle =
                    TextStyle(fontFamily: "simkai", color: Colors.green[400]);
                _aria2PlatformAddress.text = info.platformUrl!;
                _aria2RPCVer.text = info.jsonRPCVer!;
                _aria2Password.text = info.ariaToken!;
              });
            }
          }
        }
      }
    } catch (e) {
      yuukaLogger.e(e.toString());
    } finally {
      hayaseYuukaDataEngine.close();
    }
    yuukaLogger.i("Aria2 Settins Page init done!");
  }

  bool _hideToken = true;

  void changeTokenBeSeenState() {
    if (mounted) {
      setState(() {
        _hideToken = !_hideToken;
      });
    }
  }

  _aria2SaveData() async {
    bool vaildData = true;
    if (_aria2PlatformAddress.text.trim().isEmpty) {
      vaildData = false;
    }
    if ((!_aria2PlatformAddress.text.startsWith("http://")) &&
        (!_aria2PlatformAddress.text.startsWith("https://"))) {
      vaildData = false;
    }
    if (_aria2RPCVer.text.trim().isEmpty) {
      vaildData = false;
    }
    if (_aria2Password.text.trim().isEmpty) {
      vaildData = false;
    }

    if (!vaildData) {
      yuukaLogger.i("校验未通过，弹出提示框");
      return commonErrorDialog(
          context, "提示", "你需要完整输入所有内容，或者检查平台地址是否符合 url 格式", "我知道了");
    }
    yuukaLogger.i("校验通过，开始保存数据");
    YuukaDownPlatform thisYuukaInfo = YuukaDownPlatform(ObjectId(), "Aria2",
        platformUrl: _aria2PlatformAddress.text,
        jsonRPCVer: _aria2RPCVer.text,
        ariaToken: _aria2Password.text);
    yuukaLogger.i("thisYuukaInfo.id.toString():${thisYuukaInfo.id}");
    yuukaLogger.i(
        "thisYuukaInfo.downloaderPlatform:${thisYuukaInfo.downloaderPlatform}");
    yuukaLogger.i("thisYuukaInfo.platformUrl:${thisYuukaInfo.platformUrl!}");
    yuukaLogger.i("thisYuukaInfo.jsonRPCVer:${thisYuukaInfo.jsonRPCVer!}");
    yuukaLogger.i("thisYuukaInfo.ariaToken:${thisYuukaInfo.ariaToken!}");
    var hayaseYuukaDataEngineConfig = Configuration.local(
        [YuukaDownPlatform.schema],
        path: "./yuukaDownloader.realm");
    var hayaseYuukaDataEngine = Realm(hayaseYuukaDataEngineConfig);
    try {
      final existYuukaInfo = hayaseYuukaDataEngine.query<YuukaDownPlatform>(
          "downloaderPlatform == \$0", [thisYuukaInfo.downloaderPlatform]);
      if (existYuukaInfo.isEmpty) {
        yuukaLogger.i("没有 ${thisYuukaInfo.downloaderPlatform} 平台数据，需要 Insert");
        hayaseYuukaDataEngine.write(
            () => hayaseYuukaDataEngine.add<YuukaDownPlatform>(thisYuukaInfo));
      } else {
        yuukaLogger.i("存在 ${thisYuukaInfo.downloaderPlatform} 平台数据，需要 Update");
        for (var info in existYuukaInfo) {
          if (info.downloaderPlatform == thisYuukaInfo.downloaderPlatform) {
            thisYuukaInfo.id = info.id;
            yuukaLogger.i("thisYuukaInfo==>Use Exist ID:${thisYuukaInfo.id}");
          }
        }
        hayaseYuukaDataEngine.write(() => hayaseYuukaDataEngine
            .add<YuukaDownPlatform>(thisYuukaInfo, update: true));
      }
      if (mounted) {
        setState(() {
          _aria2SettingedStatus = "已设置";
          _aria2SettingedTextStyle =
              TextStyle(fontFamily: "simkai", color: Colors.green[400]);
        });
      }
      return commonSuccessDialog(
        context, "提示", "数据校验通过，保存数据成功！", "我知道了",
        // 手动指定点击 TextButton 的方法
        //     interactiveFunction: () {
        //   Navigator.of(context)
        //       .popUntil(ModalRoute.withName("/downloadPlatformSettingEntryPage"));
        // }
      );
    } catch (e) {
      return commonErrorDialog(context, "寄啦", "数据校验通过，保存数据失败！失败原因：$e", "我知道了");
    } finally {
      hayaseYuukaDataEngine.close();
    }
  }

  _testAria2Status() async {
    var hayaseYuukaDataEngineConfig = Configuration.local(
        [YuukaDownPlatform.schema],
        path: "./yuukaDownloader.realm");
    var hayaseYuukaDataEngine = Realm(hayaseYuukaDataEngineConfig);
    late YuukaDownPlatform aria2Settings;
    try {
      final existYuukaInfo = hayaseYuukaDataEngine
          .query<YuukaDownPlatform>("downloaderPlatform == \$0", ["Aria2"]);
      if (existYuukaInfo.isEmpty) {
        return commonErrorDialog(
            context, "寄啦", "数据库内没有找到连接参数，你需要先配置连接参数", "我知道了");
      } else {
        for (var info in existYuukaInfo) {
          if (info.downloaderPlatform == "Aria2") {
            aria2Settings = info;
            // yuukaLogger.i("aria2Settings.id.toString():" + aria2Settings.id.toString());
            // yuukaLogger.i("aria2Settings.downloaderPlatform:" +
            //     aria2Settings.downloaderPlatform);
            // yuukaLogger.i("aria2Settings.platformUrl:" + aria2Settings.platformUrl!);
            // yuukaLogger.i("aria2Settings.jsonRPCVer:" + aria2Settings.jsonRPCVer!);
            // yuukaLogger.i("aria2Settings.ariaToken:" + aria2Settings.ariaToken!);
            List result = await getAria2Status(aria2Settings);
            int statusCode = 0;
            Aria2RequestReturn? serverResponse;
            bool requestStatus = false;

            statusCode = result[0];
            if (result[1].toString().isNotEmpty) {
              serverResponse = result[1];
              requestStatus = true;
            } else {
              requestStatus = false;
            }

            if (!requestStatus) {
              if (mounted) {
                return commonErrorDialog(
                    context, "寄啦", "网络请求失败，请检查服务器和网络，稍后再次重试", "我知道了");
              }
            } else {
              if (statusCode == 200) {
                if (mounted) {
                  return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "成功",
                            style: styleFontSimkai,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/operationSuccessYuuka.jpg",
                                width: 200,
                              ),
                              const Row(
                                children: [
                                  Text("Aria2 服务器已经准备好使用!",
                                      style: TextStyle(
                                          fontFamily: "simkai",
                                          color: Colors.greenAccent)),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    "服务器响应:",
                                    style: TextStyle(
                                        fontFamily: "simkai",
                                        color: Colors.greenAccent),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "\t\t请求ID:${serverResponse!.id!}",
                                    style: styleFontSimkai,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "\t\tjsonRPC Ver:${serverResponse.jsonrpc!}",
                                    style: styleFontSimkai,
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    "服务器状态:",
                                    style: TextStyle(
                                        fontFamily: "simkai",
                                        color: Colors.greenAccent),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t下载速度(M/s):${serverResponse.result!.downloadSpeed}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t上传速度(M/s):${serverResponse.result!.uploadSpeed}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t活动任务:${serverResponse.result!.numActive}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t停止任务:${serverResponse.result!.numStopped}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t停止任务总数:${serverResponse.result!.numStoppedTotal}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\t\t等待任务:${serverResponse.result!.numWaiting}",
                                        style: styleFontSimkai,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: Text(
                                  "好耶~",
                                  style: styleFontSimkai,
                                ))
                          ],
                        );
                      });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        return commonErrorDialog(context, "寄啦", "失败原因：$e", "我知道了");
      }
    } finally {
      hayaseYuukaDataEngine.close();
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
                "配置 Aria2",
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
                    "Aria2",
                    style: TextStyle(
                        fontFamily: "simkai",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    "这里是 Aria2 的设置界面，设置好咯记得保存和测试~",
                    style: styleFontSimkai,
                  )
                ],
              ),
              Container(
                height: 20,
              ),
              Image.asset(
                "assets/images/downloadPlatformConfig.jpg",
                width: scrSize.width / 3.5,
              ),
              Row(
                children: [
                  Text(
                    "当前 Aria2 的设置状态: $_aria2SettingedStatus",
                    style: _aria2SettingedTextStyle,
                  )
                ],
              ),
              Row(
                children: [
                  const Text("        "),
                  Text("Aria2 服务端地址:", style: styleFontSimkai),
                  // 需要使用 Flexible 包一层的原因：
                  // https://stackoverflow.com/questions/45986093/textfield-inside-of-row-causes-layout-exception-unable-to-calculate-size
                  const Text("    "),
                  Flexible(
                    child: TextFormField(
                      controller: _aria2PlatformAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return value!.trim().isNotEmpty ? null : "服务端地址不能为空";
                      },
                      decoration: InputDecoration(
                          // border: LinearBorder(),
                          // borderRadius:
                          //     BorderRadius.all(Radius.circular(50))),
                          prefixIcon: const Icon(Icons.link),
                          label: const Text(
                              "在这里输入 Aria2 平台的地址，格式:【协议://地址(IP/域名):端口(如果是非标端口/jsonrpc)】"),
                          labelStyle: styleFontSimkai),
                    ),
                  ),
                  const Text("        "),
                ],
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  const Text("        "),
                  Text("Aria2 RPC 版本  :", style: styleFontSimkai),
                  const Text("    "),
                  Flexible(
                    child: TextFormField(
                      controller: _aria2RPCVer,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return value!.trim().isNotEmpty ? null : "RPC 版本不能为空";
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.api_rounded),
                          label: const Text("在这里输入 Aria2 RPC 版本，这个值通常为：“2.0”"),
                          labelStyle: styleFontSimkai),
                    ),
                  ),
                  const Text("        "),
                ],
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  const Text("        "),
                  Text("Aria2 通信密钥  :", style: styleFontSimkai),
                  const Text("    "),
                  Flexible(
                    child: TextFormField(
                      controller: _aria2Password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return value!.trim().isNotEmpty ? null : "通信密钥不能为空";
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          label: const Text("在这里输入 Aria2 通信密钥"),
                          labelStyle: styleFontSimkai),
                      obscureText: _hideToken,
                    ),
                  ),
                  IconButton(
                      onPressed: changeTokenBeSeenState,
                      icon: const Icon(Icons.remove_red_eye)),
                  const Text("        "),
                ],
              ),
              Container(
                height: 50,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  _aria2SaveData();
                },
                label: Text(
                  "戳我保存数据",
                  style: styleFontSimkai,
                ),
              ),
              Container(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.accessible_forward_outlined),
                onPressed: () async {
                  _testAria2Status();
                },
                label: Text(
                  "戳我对平台连通性进行测试",
                  style: styleFontSimkai,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
