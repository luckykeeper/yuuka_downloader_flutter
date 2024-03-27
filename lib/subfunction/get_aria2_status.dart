import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yuuka_downloader_flutter/model/aria2_model.dart';
import 'package:yuuka_downloader_flutter/model/model.dart';
import 'package:yuuka_downloader_flutter/subfunction/generate_random_id.dart';

Future<List> getAria2Status(YuukaDownPlatform aria2Settings) async {
  String requestID = generateRandomID();
  final yuukaRequestClient = Dio();
  var request = Aria2Request(
      id: requestID,
      jsonrpc: aria2Settings.jsonRPCVer,
      method: "aria2.getGlobalStat",
      params: ["token:${aria2Settings.ariaToken!}"]);
  var response = await yuukaRequestClient.post(aria2Settings.platformUrl!,
      data: request.toJson(),
      options: Options(
          headers: {HttpHeaders.userAgentHeader: "YuukaDownloaderFlutter"},
          sendTimeout: const Duration(seconds: 1),
          receiveTimeout: const Duration(seconds: 1)));
  // print(response.statusCode);
  // print(response.statusMessage);
  // print(response.toString());
  if (response.statusCode.toString().isNotEmpty) {
    var serverReturn = Aria2RequestReturn.fromJson(jsonDecode(response.data));
    return [response.statusCode, serverReturn];
  } else {
    return [0];
  }
}
