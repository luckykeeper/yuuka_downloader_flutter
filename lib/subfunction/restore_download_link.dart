import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';

Future<String> restoreDownloadLink(YuukaDownGalDB downloadInfo) async {
  if (int.parse(downloadInfo.partNum!) > 1) {
    yuukaLogger.d(
        "还原多 part数据: ${downloadInfo.downloadBaseUrl!}.part${downloadInfo.partNum!}.${downloadInfo.fileType!}");
    return "${downloadInfo.downloadBaseUrl!}.part${downloadInfo.partNum!}.${downloadInfo.fileType!}";
  } else {
    yuukaLogger.d(
        "还原单文件数据: ${downloadInfo.downloadBaseUrl!}.${downloadInfo.fileType!}");
    return "${downloadInfo.downloadBaseUrl!}.${downloadInfo.fileType!}";
  }
}
