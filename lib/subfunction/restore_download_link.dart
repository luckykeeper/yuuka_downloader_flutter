import 'package:yuuka_downloader_flutter/model/model.dart';

Future<String> restoreDownloadLink(YuukaDownGalDB downloadInfo) async {
  if (int.parse(downloadInfo.partNum!) > 1) {
    return "${downloadInfo.downloadBaseUrl!}.part${downloadInfo.partNum!}.${downloadInfo.fileType!}";
  } else {
    return "${downloadInfo.downloadBaseUrl!}.${downloadInfo.fileType!}";
  }
}
