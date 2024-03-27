import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/restore_download_link.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({super.key});

  @override
  State<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  List<Widget> searchResultWidgets = [];
  final TextEditingController _searchTitleController = TextEditingController();
  final TextEditingController _searchSubAreaController =
      TextEditingController();

  bool firstRander = true;

  var hayaseYuukaDataEngine = Realm(Configuration.local([YuukaDownGalDB.schema],
      path: "./yuukaDownloader.realm"));

  @override
  void dispose() {
    try {
      hayaseYuukaDataEngine.close();
    } catch (e) {
      yuukaLogger.e(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // https://juejin.cn/post/6844904190599233544
    /// 生成 ExpansionTile 下的 ListView 的单个组件
    Widget generateWidget(YuukaDownGalDB item) {
      /// 使用该组件可以使宽度撑满
      return FractionallySizedBox(
        widthFactor: 1,
        child: TextButton.icon(
          onPressed: () async {
            try {
              await Clipboard.setData(
                  ClipboardData(text: await restoreDownloadLink(item)));
              BotToast.showSimpleNotification(
                  duration: const Duration(seconds: 2),
                  hideCloseButton: false,
                  backgroundColor: Colors.green[300],
                  title: "下载链接复制到剪贴板成功!",
                  titleStyle: styleFontSimkai);
            } catch (e) {
              BotToast.showSimpleNotification(
                  duration: const Duration(seconds: 2),
                  hideCloseButton: false,
                  backgroundColor: Colors.pinkAccent,
                  title: "下载链接复制到剪贴板失败:$e",
                  titleStyle: styleFontSimkai);
            }
          },
          label: Text(
            item.galgameName,
            style: styleFontSimkai,
            overflow: TextOverflow.ellipsis,
          ),
          icon: const Icon(Icons.receipt),
        ),
      );
    }

    /// 生成 ExpansionTile 组件 , children 是 List<Widget> 组件
    Widget generateExpansionTileWidget(
        titleText, List<YuukaDownGalDB>? galInfos,
        {String? searchTitle, String? searchSubArea}) {
      Map<String, List<YuukaDownGalDB>> galgameInfoMap =
          <String, List<YuukaDownGalDB>>{};

      // yuukaLogger.i("generateExpansionTileWidget 当前搜索标题：${searchTitle}");
      // yuukaLogger.i("generateExpansionTileWidget 当前搜索分区：${searchSubArea}");

      // yuukaLogger.i("searchTitle:$searchTitle");
      if (searchTitle != null) {
        try {
          final existGalInfoList = hayaseYuukaDataEngine.all<YuukaDownGalDB>();
          if (existGalInfoList.isNotEmpty) {
            if (searchSubArea!.isNotEmpty) {
              for (var item in existGalInfoList) {
                var nameToLower = item.galgameName.toLowerCase();
                if (nameToLower.contains(searchTitle.toLowerCase())) {
                  if (searchSubArea == item.subArea) {
                    // yuukaLogger.i("当前入列:${item.galgameName}");
                    // galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
                    if (galgameInfoMap[item.subArea!] == null) {
                      galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
                    } else {
                      galgameInfoMap[item.subArea!]!.add(item);
                    }
                  }
                }
              }
            } else {
              for (var item in existGalInfoList) {
                var nameToLower = item.galgameName.toLowerCase();
                if (nameToLower.contains(searchTitle)) {
                  // yuukaLogger.i("当前入列:${item.galgameName}");
                  // galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
                  if (galgameInfoMap[item.subArea!] == null) {
                    galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
                  } else {
                    galgameInfoMap[item.subArea!]!.add(item);
                  }
                }
              }
            }
          } else {
            yuukaLogger.i("列表是空的……");
          }
        } catch (e) {
          yuukaLogger.e("searchTitle E!:$searchTitle");

          yuukaLogger.e(e.toString());
        }
      } else {
        try {
          final existGalInfoList = hayaseYuukaDataEngine.all<YuukaDownGalDB>();
          if (existGalInfoList.isNotEmpty) {
            for (var item in existGalInfoList) {
              // galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
              if (galgameInfoMap[item.subArea!] == null) {
                galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
              } else {
                galgameInfoMap[item.subArea!]!.add(item);
              }
            }
          }
        } catch (e) {
          yuukaLogger.e(e.toString());
        }
      }

      if (galgameInfoMap[titleText] != null) {
        if (!firstRander) {
          BotToast.showSimpleNotification(
              duration: const Duration(seconds: 2),
              hideCloseButton: false,
              backgroundColor: Colors.green[300],
              title: "搜索成功~",
              titleStyle: styleFontSimkai);
        }

        return Builder(builder: (context) {
          List<Widget> thisWidgetList = [];
          for (var item in galgameInfoMap[titleText]!) {
            thisWidgetList.add(generateWidget(item));
            thisWidgetList.add(Container(
              height: 20,
            ));
          }
          return ExpansionTile(
            title: Text(
              titleText,
              style: const TextStyle(fontFamily: "simkai", fontSize: 20),
            ),
            children: thisWidgetList,
          );
        });
      } else {
        if (searchSubArea!.isNotEmpty) {
          if (searchSubArea == titleText) {
            BotToast.showSimpleNotification(
                duration: const Duration(seconds: 2),
                hideCloseButton: false,
                backgroundColor: Colors.pinkAccent,
                title: "没有搜索到任何结果……",
                titleStyle: styleFontSimkai);
          }
        } else {
          BotToast.showSimpleNotification(
              duration: const Duration(seconds: 2),
              hideCloseButton: false,
              backgroundColor: Colors.green[300],
              title: "搜索成功~",
              titleStyle: styleFontSimkai);
        }

        return Container();
      }
    }

    /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
    List<Widget> buildList({String? searchTitle, String? searchSubArea}) {
      List<Widget> widgets = [];

      Map<String, List<YuukaDownGalDB>> galgameInfoMap =
          <String, List<YuukaDownGalDB>>{};

      // yuukaLogger.i("buildList 当前搜索标题：${searchTitle}");
      // yuukaLogger.i("buildList 当前搜索分区：${searchSubArea}");

      try {
        final existGalInfoList = hayaseYuukaDataEngine.all<YuukaDownGalDB>();
        if (existGalInfoList.isNotEmpty) {
          for (var item in existGalInfoList) {
            // galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
            if (galgameInfoMap[item.subArea!] == null) {
              galgameInfoMap.putIfAbsent(item.subArea!, () => [item]);
            } else {
              galgameInfoMap[item.subArea!]!.add(item);
            }
          }
        }
      } catch (e) {
        yuukaLogger.e(e.toString());
      }

      widgets.add(
        const Row(
          children: [
            Text(
              "可以在这里查看下载过的 gal 的数据，点击名称可以复制本程序可用的下载链接，用于下发下载任务页再次下载",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "simkai"),
            ),
          ],
        ),
      );
      widgets.add(
        Column(children: [
          const Divider(),
          Container(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchTitleController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    return value!.trim().isNotEmpty ? null : "搜索标题不能为空";
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.title),
                      label: const Text("输入要搜索的标题"),
                      labelStyle: styleFontSimkai),
                  style: styleFontSimkai,
                ),
              ),
              Text(
                "在此分区搜索:",
                style: styleFontSimkai,
              ),
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
                      yuukaLogger.i("当前选择的分区:${_searchSubAreaController.text}");
                    } catch (e) {
                      yuukaLogger.e("SubArea onSelect->e:$e");
                      yuukaLogger
                          .i("当前选择的分区(catch):${_searchSubAreaController.text}");
                    }
                  }

                  return DropdownMenu<String>(
                    textStyle: styleFontSimkai,
                    controller: _searchSubAreaController,
                    onSelected: onSelect,
                    dropdownMenuEntries:
                        buildMenuList(galgameInfoMap.keys.toList()),
                    leadingIcon: const Icon(Icons.title_rounded),
                    trailingIcon: const Icon(Icons.select_all),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                  );
                },
              ),
              IconButton(
                  onPressed: () async {
                    // if (_searchTitleController.text.isNotEmpty) {
                    setState(() {
                      searchResultWidgets = buildList(
                          searchTitle: _searchTitleController.text,
                          searchSubArea: _searchSubAreaController.text);
                    });
                    // } else {
                    // return commonErrorDialog(
                    // context, "寄啦", "不输入搜索标题怎么搜索？！！", "我是阿露");
                    // }
                  },
                  icon: const Icon(Icons.search)),
            ],
          )
        ]),
      );
      for (var key in galgameInfoMap.keys) {
        widgets.add(generateExpansionTileWidget(key, galgameInfoMap[key],
            searchTitle: searchTitle, searchSubArea: searchSubArea));
      }
      return widgets;
    }

    if (firstRander) {
      setState(() {
        searchResultWidgets = buildList();
      });
      firstRander = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "搜索历史数据库",
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
        children: searchResultWidgets,
      ),
    );
  }
}
