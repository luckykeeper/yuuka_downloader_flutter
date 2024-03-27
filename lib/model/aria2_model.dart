import 'package:yuuka_downloader_flutter/subfunction/yuuka_logger.dart';

class Aria2Request {
  String? jsonrpc;
  String? id;
  String? method;
  List<String>? params;

  Aria2Request({this.jsonrpc, this.id, this.method, this.params});

  Aria2Request.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    method = json['method'];
    params = json['params'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    data['method'] = method;
    data['params'] = params;
    return data;
  }
}

class Aria2RequestReturn {
  String? id;
  String? jsonrpc;
  Result? result;
  Error? error;

  Aria2RequestReturn({this.id, this.jsonrpc, this.result, this.error});

  Aria2RequestReturn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jsonrpc = json['jsonrpc'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
    error = json['error'] != null ? Error.fromJson(json['error']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['jsonrpc'] = jsonrpc;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    if (error != null) {
      data['error'] = error!.toJson();
    }
    return data;
  }
}

class Result {
  String? downloadSpeed;
  String? numActive;
  String? numStopped;
  String? numStoppedTotal;
  String? numWaiting;
  String? uploadSpeed;

  Result(
      {this.downloadSpeed,
      this.numActive,
      this.numStopped,
      this.numStoppedTotal,
      this.numWaiting,
      this.uploadSpeed});

  Result.fromJson(Map<String, dynamic> json) {
    try {
      downloadSpeed =
          (int.tryParse(json['downloadSpeed'])! / 1048576).toString();
    } catch (e) {
      yuukaLogger.e("下载速度解析失败:${e.toString()}");
      downloadSpeed = json['downloadSpeed'];
    }
    numActive = json['numActive'];
    numStopped = json['numStopped'];
    numStoppedTotal = json['numStoppedTotal'];
    numWaiting = json['numWaiting'];
    try {
      uploadSpeed = (int.tryParse(json['uploadSpeed'])! / 1048576).toString();
    } catch (e) {
      yuukaLogger.e("上传速度解析失败:${e.toString()}");
      uploadSpeed = json['uploadSpeed'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['downloadSpeed'] = downloadSpeed;
    data['numActive'] = numActive;
    data['numStopped'] = numStopped;
    data['numStoppedTotal'] = numStoppedTotal;
    data['numWaiting'] = numWaiting;
    data['uploadSpeed'] = uploadSpeed;
    return data;
  }
}

class Error {
  int? code;
  String? message;

  Error({this.code, this.message});

  Error.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}
