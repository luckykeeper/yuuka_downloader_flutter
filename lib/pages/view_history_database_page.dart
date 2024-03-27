import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/restore_download_link.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

class ViewHistoryDatabasePage extends StatefulWidget {
  const ViewHistoryDatabasePage({super.key});

  @override
  State<ViewHistoryDatabasePage> createState() =>
      _ViewHistoryDatabasePageState();
}

class _ViewHistoryDatabasePageState extends State<ViewHistoryDatabasePage> {
  // ignore: unnecessary_new
  var hayaseYuukaDataEngine = new Realm(Configuration.local(
      [YuukaDownGalDB.schema],
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
    Map<String, List<YuukaDownGalDB>> galgameInfoMap =
        <String, List<YuukaDownGalDB>>{};

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
    // for (var element in galgameInfoMap["game"]!) {
    // yuukaLogger.i("thisItem:${element.galgameName}");
    // }
    // https://juejin.cn/post/6844904190599233544
    /// 生成 ExpansionTile 下的 ListView 的单个组件
    Widget generateWidget(YuukaDownGalDB item) {
      // yuukaLogger.i("当前生成Item：${item.galgameName}");

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
        titleText, List<YuukaDownGalDB>? galInfos) {
      return Builder(builder: (context) {
        List<Widget> thisWidgetList = [];
        for (var item in galgameInfoMap[titleText]!) {
          // yuukaLogger.i("调用generateWidget:${item.galgameName}");
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
    }

    /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
    List<Widget> buildList() {
      List<Widget> widgets = [];
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
        ]),
      );
      for (var key in galgameInfoMap.keys) {
        // yuukaLogger.i("early=>[$key]->[${galgameInfoMap[key].toString()}]");
        widgets.add(generateExpansionTileWidget(key, galgameInfoMap[key]));
      }
      return widgets;
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "查看历史数据库",
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
        children: buildList(),
      ),
    );
  }
}
