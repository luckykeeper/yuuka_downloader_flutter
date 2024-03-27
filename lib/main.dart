import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yuuka_downloader_flutter/pages/aria2_setting_page.dart';
import 'package:yuuka_downloader_flutter/pages/download_platform_setting_entry_page.dart';
import 'package:yuuka_downloader_flutter/pages/download_quest_page.dart';
import 'package:yuuka_downloader_flutter/pages/history_database_entry_page.dart';
import 'package:yuuka_downloader_flutter/pages/history_database_migrate_page.dart';
import 'package:yuuka_downloader_flutter/pages/search_history_database_page.dart';
import 'package:yuuka_downloader_flutter/pages/view_history_database_page.dart';
import 'package:yuuka_downloader_flutter/pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1024, 768),
    minimumSize: Size(1024, 768),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const YuukaDownloader());
}

class YuukaDownloader extends StatelessWidget {
  const YuukaDownloader({super.key});

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(primary: Colors.cyan),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.cyan),
      ),
      // home: WelcomePage(),
      navigatorObservers: [BotToastNavigatorObserver()],
      builder: botToastBuilder,
      routes: {
        "/": (context) => const WelcomePage(),
        "/downloadPlatformSettingEntryPage": (context) =>
            const DownloadPlatformSettingEntryPage(),
        "/downloadPlatformSettingEntryPage/aria2Settings": (context) =>
            const Aria2SettingPage(),
        "/downloadQuestPage": (context) => const DownloadQuestPage(),
        "/historyDatabaseEntryPage": (context) =>
            const HistoryDatabaseEntryPage(),
        "/historyDatabaseEntryPage/viewHistoryDatabase": (context) =>
            const ViewHistoryDatabasePage(),
        "/historyDatabaseEntryPage/searchHistoryDatabase": (context) =>
            const SearchHistoryPage(),
        "/historyDatabaseEntryPage/historyDatabaseMigrate": (context) =>
            const HistoryDatabaseMigratePage(),
      },
    );
  }
}
