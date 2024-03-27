import 'package:realm/realm.dart';
import 'package:yuuka_downloader_flutter/model/download_link_analyze_result_model.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';

void saveOrUpdateInfoToDatabase(
    DownloadLinkAnalyzeResult galgameInfo, String saveName) {
  var hayaseYuukaDataEngineConfig = Configuration.local([YuukaDownGalDB.schema],
      path: "./yuukaDownloader.realm");
  var hayaseYuukaDataEngine = Realm(hayaseYuukaDataEngineConfig);
  String thisDownloadBaseUrl =
      "${galgameInfo.analysisResult["protocol"]!}://${galgameInfo.analysisResult["prefix"]!}llgal.xyz/${galgameInfo.analysisResult["subArea"]!}/${galgameInfo.analysisResult["baseUrl"]!}";
  yuukaLogger.d("thisDownloadBaseUrl: $thisDownloadBaseUrl");
  YuukaDownGalDB thisGalInfo = YuukaDownGalDB(ObjectId(), saveName,
      // downloadBaseUrl: downloadLinkListGenerator(galgameInfo).last,
      downloadBaseUrl: thisDownloadBaseUrl,
      partNum: galgameInfo.analysisResult["partNum"],
      fileType: galgameInfo.analysisResult["fileType"],
      subArea: galgameInfo.analysisResult["subArea"]);
  try {
    final existGalInfo = hayaseYuukaDataEngine
        .query<YuukaDownGalDB>("galgameName == \$0", [thisGalInfo.galgameName]);
    if (existGalInfo.isEmpty) {
      yuukaLogger.i("没有名为 ${thisGalInfo.galgameName} 的数据，需要 Insert");
      hayaseYuukaDataEngine
          .write(() => hayaseYuukaDataEngine.add<YuukaDownGalDB>(thisGalInfo));
    } else {
      yuukaLogger.i("存在名为 ${thisGalInfo.galgameName} 的数据，需要 Update");
      for (var info in existGalInfo) {
        if (info.galgameName == thisGalInfo.galgameName) {
          thisGalInfo.id = info.id;
          yuukaLogger.i("thisGalInfo==>Use Exist ID:${thisGalInfo.id}");
        }
      }
      hayaseYuukaDataEngine.write(() =>
          hayaseYuukaDataEngine.add<YuukaDownGalDB>(thisGalInfo, update: true));
    }
  } catch (e) {
    yuukaLogger.e("保存gal数据到数据库失败:$e");
  } finally {
    hayaseYuukaDataEngine.close();
  }
}
