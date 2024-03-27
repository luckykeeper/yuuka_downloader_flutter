import 'package:yuuka_downloader_flutter/model/download_link_analyze_result_model.dart';

List<String> downloadLinkListGenerator(DownloadLinkAnalyzeResult downloadInfo) {
  List<String> downloadLinkList = [];
  if (int.parse(downloadInfo.analysisResult["partNum"]!) > 1) {
    for (var i = 0;
        i < int.parse(downloadInfo.analysisResult["partNum"]!);
        i++) {
      String thisDownloadLink = "";
      thisDownloadLink = "${downloadInfo.analysisResult["protocol"]!}://";
      if (downloadInfo.analysisResult["prefix"]!.isNotEmpty) {
        thisDownloadLink += "${downloadInfo.analysisResult["prefix"]!}.";
      }
      thisDownloadLink +=
          "llgal.xyz/${downloadInfo.analysisResult["subArea"]!}/${downloadInfo.analysisResult["baseUrl"]!}.part${i + 1}.${downloadInfo.analysisResult["fileType"]!}";
      downloadLinkList.add(thisDownloadLink);
    }
  } else {
    String thisDownloadLink = "";
    thisDownloadLink = "${downloadInfo.analysisResult["protocol"]!}://";
    if (downloadInfo.analysisResult["prefix"]!.isNotEmpty) {
      thisDownloadLink += downloadInfo.analysisResult["prefix"]!;
    }
    thisDownloadLink +=
        "llgal.xyz/${downloadInfo.analysisResult["subArea"]!}/${downloadInfo.analysisResult["baseUrl"]!}.${downloadInfo.analysisResult["fileType"]!}";
    downloadLinkList.add(thisDownloadLink);
  }
  return downloadLinkList;
}
