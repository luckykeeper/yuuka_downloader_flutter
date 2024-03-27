import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/theme/font.dart';

class HistoryDatabaseEntryPage extends StatelessWidget {
  const HistoryDatabaseEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size scrSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(
                "历史数据库",
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
                    "可以在这里查看、搜索历史数据库，或从 Golang 版本的数据库迁移数据到本库",
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
              Image.asset(
                "assets/images/historyDatabase.gif",
                width: scrSize.width / 4,
              ),
              Row(
                children: [
                  const Text(
                    "        ",
                  ),
                  Text(
                    "在下面选择要进行的操作:",
                    style: styleFontSimkai,
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.import_contacts),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          "/historyDatabaseEntryPage/viewHistoryDatabase");
                    },
                    label: Text(
                      "查看历史数据库",
                      style: styleFontSimkai,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          "/historyDatabaseEntryPage/searchHistoryDatabase");
                    },
                    label: Text(
                      "搜索历史数据库",
                      style: styleFontSimkai,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.import_export),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          "/historyDatabaseEntryPage/historyDatabaseMigrate");
                    },
                    label: Text(
                      "从 Golang 版本迁移数据到本库",
                      style: styleFontSimkai,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
