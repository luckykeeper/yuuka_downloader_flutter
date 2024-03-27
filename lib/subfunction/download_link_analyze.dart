import 'package:yuuka_downloader_flutter/model/download_link_analyze_result_model.dart';
import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';

Future<DownloadLinkAnalyzeResult> downloadLinkAnalyze(
    String yngalDownloadLink, String? prefix) async {
  DownloadLinkAnalyzeResult result = DownloadLinkAnalyzeResult();
  try {
    yuukaLogger.i("送解析 url: $yngalDownloadLink");
    if (prefix != null) {
      yuukaLogger.i("送解析前缀: $prefix");
    }
    String urlToAnalyze = "";
    // 协议校验
    var protocol = yngalDownloadLink.split("://")[0];
    if (((protocol == "http") || (protocol == "https")) &&
        (yngalDownloadLink.split("://").length == 2)) {
      result.analysisResult["protocol"] = yngalDownloadLink.split("://")[0];
      urlToAnalyze = yngalDownloadLink.split("://")[1];
      // 前缀校验
      if (yngalDownloadLink.split("llgal.xyz/").length == 2) {
        if (prefix == null) {
          result.analysisResult["prefix"] = urlToAnalyze.split("llgal.xyz/")[0];
        } else {
          result.analysisResult["prefix"] = prefix;
        }
        // 提取分区
        urlToAnalyze = urlToAnalyze.split("llgal.xyz/")[1];
        if (urlToAnalyze.split("/").length >= 2) {
          result.analysisResult["subArea"] = urlToAnalyze.split("/")[0];
          // 提取文件夹名称

          // 删除路径中的分区
          urlToAnalyze = urlToAnalyze
              .substring(result.analysisResult["subArea"]!.length + 1);
          for (var name in urlToAnalyze.split("/")) {
            if (name.contains(RegExp(".part[1-9]"))) {
              name = name.split(".part").first;
            }
            if (name.contains(".rar")) {
              name = name.split(".rar").first;
            }
            result.gameNameOptions.add(Uri.decodeFull(name));
          }
          // 提取文件类型
          yuukaLogger.i("urlToAnalyze:$urlToAnalyze");
          if (urlToAnalyze.contains(".")) {
            result.analysisResult["fileType"] = urlToAnalyze.split(".").last;
            // 检测多 part & 获取 base url
            if (urlToAnalyze.contains(RegExp(".part[1-9]"))) {
              var partInfo = urlToAnalyze.split(".part").last;
              if (partInfo.split(".").length == 2) {
                result.analysisResult["partNum"] = partInfo.split(".").first;
                result.analysisResult["baseUrl"] =
                    urlToAnalyze.split(".part").first;
              } else {
                result.analyzeResultBool = false;
                result.analysisResult["errMsg"] = "多 part 匹配失败，链接疑似有误？？？";
                return result;
              }
            } else {
              result.analysisResult["partNum"] = "1";
              result.analysisResult["baseUrl"] = urlToAnalyze
                  .split(".${result.analysisResult["fileType"]!}")
                  .first;
            }
            result.analyzeResultBool = true;
          } else {
            result.analyzeResultBool = false;
            result.analysisResult["errMsg"] = "文件类型匹配失败，链接疑似有误？？？";
            return result;
          }
        } else {
          result.analyzeResultBool = false;
          result.analysisResult["errMsg"] = "路径匹配失败，链接疑似有误？？？";
          return result;
        }
      } else {
        result.analyzeResultBool = false;
        result.analysisResult["errMsg"] = "下载站点匹配失败，疑似非初音站链接？？？";
        return result;
      }
    } else {
      result.analyzeResultBool = false;
      result.analysisResult["errMsg"] = "链接格式校验失败，疑似非 url 链接？？？";
      return result;
    }
    return result;
  } catch (e) {
    yuukaLogger.i("downloadLinkAnalyze: 未知异常!$e");
    result.analyzeResultBool = false;
    result.analysisResult["errMsg"] = "未知异常";
    return result;
  }
}
