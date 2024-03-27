import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yuuka_downloader_flutter/model/download_quest_result.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/generate_random_id.dart';

Future<DownloadQuestResult> requestAria2Download(
    List<String> downloadQuestUrls, YuukaDownPlatform aria2Settings) async {
  var result = DownloadQuestResult();
  for (var url in downloadQuestUrls) {
    try {
      final yuukaRequestClient = Dio();
      String request =
          "{\"jsonrpc\":\"${aria2Settings.jsonRPCVer}\",\"method\":\"aria2.addUri\",\"id\":\"${generateRandomID()}\",\"params\":[\"token:${aria2Settings.ariaToken}\",[\"$url\"]]}";
      var response = await yuukaRequestClient.post(aria2Settings.platformUrl!,
          data: request,
          options: Options(
              headers: {HttpHeaders.userAgentHeader: "YuukaDownloaderFlutter"},
              sendTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 2)));
      if (response.statusCode == 200) {
        result.successCount++;
      } else {
        result.successCount--;
      }
    } catch (e) {
      result.isAllSuccessed = false;
      result.failureCount++;
      result.errMsgs.add("$url 下载异常: $e");
    }
  }
  return result;
}
