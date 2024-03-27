import 'package:realm/realm.dart';

part 'model.g.dart';

// Golang Ver. Reference Init SQL.
// sql_initialize_platform      = `CREATE TABLE yuukaDownPlatform (downloaderPlatform TEXT PRIMARY KEY NOT NULL,platformUrl TEXT,jsonRPCVer TEXT,ariaToken TEXT);`
// sql_initialize_galDB         = `CREATE TABLE yuukaDownGalDB (galgameName TEXT PRIMARY KEY NOT NULL,downloadBaseUrl TEXT NOT NULL,partNum TEXT NOT NULL,fileType TEXT NOT NULL,subArea TEXT NOT NULL);`

// doc:https://www.mongodb.com/docs/realm/sdk/flutter/realm-database/model-data/data-types/#additional-supported-data-types

@RealmModel()
class _YuukaDownPlatform {
  @PrimaryKey()
  late ObjectId id;
  late String downloaderPlatform;

  late String? platformUrl;
  late String? jsonRPCVer;
  late String? ariaToken;
}

@RealmModel()
class _YuukaDownGalDB {
  @PrimaryKey()
  late ObjectId id;

  late String galgameName;

  late String? downloadBaseUrl;
  late String? partNum;
  late String? fileType;
  late String? subArea;
}
