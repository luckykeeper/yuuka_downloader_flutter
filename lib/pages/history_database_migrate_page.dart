import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

class HistoryDatabaseMigratePage extends StatefulWidget {
  const HistoryDatabaseMigratePage({super.key});

  @override
  State<HistoryDatabaseMigratePage> createState() =>
      _HistoryDatabaseMigratePageState();
}

class _HistoryDatabaseMigratePageState
    extends State<HistoryDatabaseMigratePage> {
  var hayaseYuukaDataEngine = Realm(Configuration.local([YuukaDownGalDB.schema],
      path: "./yuukaDownloader.realm"));

  @override
  void dispose() {
    try {
      hayaseYuukaDataEngine.close();
    } catch (e) {
      yuukaLogger.i(e);
    }
    super.dispose();
  }

  String _oldDbLocation = "";
  List<PlatformFile>? _oldDbPaths;
  Widget _mingrateButton = Container();

  String _dataToBeMigrated = "N/A";
  String _dataAlreadyMigrated = "N/A";

  void _pickOldDbFile() async {
    setState(() {
      _dataToBeMigrated = "N/A";
      _dataAlreadyMigrated = "N/A";
    });

    try {
      _oldDbPaths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => yuukaLogger.i(status),
        allowedExtensions: (["db"]),
        dialogTitle: ("请选择 YuukaDownloader(Golang Ver.)的数据库文件(YuukaDown.db):"),
        initialDirectory: "./",
        lockParentWindow: true,
      ))
          ?.files;
      setState(() {
        _oldDbLocation = _oldDbPaths!.first.path!;

        _mingrateButton = ElevatedButton.icon(
          onPressed: () async {
            int dataAlreadyMigratedInt = 0;
            if (_oldDbLocation.endsWith("yuukaDown.db")) {
              try {
                yuukaLogger.i("开始迁移数据");
                var oldYuukaDatabase = SqliteDatabase(path: _oldDbLocation);
                var dataCountResults = await oldYuukaDatabase
                    .getAll('SELECT COUNT(galgameName) FROM yuukaDownGalDB;');
                int dataCount = 0;
                for (var row in dataCountResults) {
                  dataCount = row.columnAt(0);
                }
                setState(() {
                  _dataToBeMigrated = dataCount.toString();
                  _dataAlreadyMigrated = dataAlreadyMigratedInt.toString();
                });
                var galgameInfos = await oldYuukaDatabase.getAll(
                    "SELECT galgameName, downloadBaseUrl, partNum, fileType, subArea FROM yuukaDownGalDB;");
                for (var item in galgameInfos) {
                  YuukaDownGalDB migrateInfo = YuukaDownGalDB(
                      ObjectId(), item.columnAt(0),
                      downloadBaseUrl: item.columnAt(1),
                      partNum: item.columnAt(2),
                      fileType: item.columnAt(3),
                      subArea: item.columnAt(4));
                  // yuukaLogger.i("thisInfo(id):${migrateInfo.id}");
                  // yuukaLogger.i("thisInfo(galgameName):${migrateInfo.galgameName}");
                  // yuukaLogger.i(
                  //     "thisInfo(downloadBaseUrl):${migrateInfo.downloadBaseUrl}");
                  // yuukaLogger.i("thisInfo(partNum):${migrateInfo.partNum}");
                  // yuukaLogger.i("thisInfo(fileType):${migrateInfo.fileType}");
                  // yuukaLogger.i("thisInfo(subArea):${migrateInfo.subArea}");
                  try {
                    var existYuukaInfo = hayaseYuukaDataEngine
                        .query<YuukaDownGalDB>(
                            "galgameName == \$0", [migrateInfo.galgameName]);
                    if (existYuukaInfo.isEmpty) {
                      hayaseYuukaDataEngine.write(() => hayaseYuukaDataEngine
                          .add<YuukaDownGalDB>(migrateInfo));
                    } else {
                      for (var info in existYuukaInfo) {
                        if (info.galgameName == migrateInfo.galgameName) {
                          migrateInfo.id = info.id;
                        }
                      }
                      hayaseYuukaDataEngine.write(() => hayaseYuukaDataEngine
                          .add<YuukaDownGalDB>(migrateInfo, update: true));
                    }
                    dataAlreadyMigratedInt++;
                    setState(() {
                      _dataAlreadyMigrated = dataAlreadyMigratedInt.toString();
                    });
                    if (dataAlreadyMigratedInt == dataCount) {
                      BotToast.showSimpleNotification(
                          duration: const Duration(seconds: 2),
                          hideCloseButton: false,
                          backgroundColor: Colors.green[300],
                          title: "数据迁移全部成功🎉",
                          titleStyle: styleFontSimkai);
                    }
                  } catch (e) {
                    BotToast.showSimpleNotification(
                        duration: const Duration(seconds: 2),
                        hideCloseButton: false,
                        backgroundColor: Colors.pink[300],
                        title: "数据迁移失败😡(${migrateInfo.galgameName}),异常信息:$e",
                        titleStyle: styleFontSimkai);
                  }
                }
              } catch (e) {
                BotToast.showSimpleNotification(
                    duration: const Duration(seconds: 2),
                    hideCloseButton: false,
                    backgroundColor: Colors.pink[300],
                    title: "数据迁移失败😡,异常信息:$e",
                    titleStyle: styleFontSimkai);
              }
            } else {
              BotToast.showSimpleNotification(
                  duration: const Duration(seconds: 2),
                  hideCloseButton: false,
                  backgroundColor: Colors.pink[300],
                  title: "数据库文件校验错误，请重新选择",
                  titleStyle: styleFontSimkai);
            }
          },
          label: Text(
            "迁移数据",
            style: styleFontSimkai,
          ),
          icon: const Icon(Icons.send),
        );
      });
      BotToast.showSimpleNotification(
          duration: const Duration(seconds: 2),
          hideCloseButton: false,
          backgroundColor: Colors.green[300],
          title: "文件选择成功~",
          titleStyle: styleFontSimkai);
    } catch (e) {
      BotToast.showSimpleNotification(
          duration: const Duration(seconds: 2),
          hideCloseButton: false,
          backgroundColor: Colors.pink[300],
          title: "文件选择失败😡,请重新选择",
          titleStyle: styleFontSimkai);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "导入 YuukaDownloader(Golang Ver.) 数据",
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
          Column(children: [
            const Row(
              children: [
                Text(
                  "迁移 Golang 版本的数据库数据到本库",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: "simkai"),
                )
              ],
            ),
            const Divider(),
            Container(
              height: 100,
            ),
            Row(
              children: [
                const Text("        "),
                Text(
                  "点击右侧按钮选择要迁移的数据库文件(yuukaDown.db):",
                  style: styleFontSimkai,
                )
              ],
            ),
            Container(
              height: 20,
            ),
            Row(
              children: [
                const Text("        "),
                Text(
                  "旧数据库文件位置:",
                  style: styleFontSimkai,
                ),
                Expanded(child: Text(_oldDbLocation, style: styleFontSimkai)),
                ElevatedButton.icon(
                  onPressed: () {
                    _pickOldDbFile();
                  },
                  label: Text(
                    "选择",
                    style: styleFontSimkai,
                  ),
                  icon: const Icon(Icons.folder_open),
                ),
                _mingrateButton,
                const Text("        "),
              ],
            ),
            Row(
              children: [
                const Text("        "),
                const Text(
                  "需要迁移数据总数: ",
                  style: TextStyle(
                      fontFamily: "simkai",
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent),
                ),
                Text(
                  _dataToBeMigrated,
                  style: styleFontSimkai,
                )
              ],
            ),
            Row(
              children: [
                const Text("        "),
                const Text(
                  "已经迁移数据总数: ",
                  style: TextStyle(
                      fontFamily: "simkai",
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent),
                ),
                Text(
                  _dataAlreadyMigrated,
                  style: styleFontSimkai,
                )
              ],
            )
          ])
        ],
      ),
    );
  }
}
