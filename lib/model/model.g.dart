// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class YuukaDownPlatform extends _YuukaDownPlatform
    with RealmEntity, RealmObjectBase, RealmObject {
  YuukaDownPlatform(
    ObjectId id,
    String downloaderPlatform, {
    String? platformUrl,
    String? jsonRPCVer,
    String? ariaToken,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'downloaderPlatform', downloaderPlatform);
    RealmObjectBase.set(this, 'platformUrl', platformUrl);
    RealmObjectBase.set(this, 'jsonRPCVer', jsonRPCVer);
    RealmObjectBase.set(this, 'ariaToken', ariaToken);
  }

  YuukaDownPlatform._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get downloaderPlatform =>
      RealmObjectBase.get<String>(this, 'downloaderPlatform') as String;
  @override
  set downloaderPlatform(String value) =>
      RealmObjectBase.set(this, 'downloaderPlatform', value);

  @override
  String? get platformUrl =>
      RealmObjectBase.get<String>(this, 'platformUrl') as String?;
  @override
  set platformUrl(String? value) =>
      RealmObjectBase.set(this, 'platformUrl', value);

  @override
  String? get jsonRPCVer =>
      RealmObjectBase.get<String>(this, 'jsonRPCVer') as String?;
  @override
  set jsonRPCVer(String? value) =>
      RealmObjectBase.set(this, 'jsonRPCVer', value);

  @override
  String? get ariaToken =>
      RealmObjectBase.get<String>(this, 'ariaToken') as String?;
  @override
  set ariaToken(String? value) => RealmObjectBase.set(this, 'ariaToken', value);

  @override
  Stream<RealmObjectChanges<YuukaDownPlatform>> get changes =>
      RealmObjectBase.getChanges<YuukaDownPlatform>(this);

  @override
  YuukaDownPlatform freeze() =>
      RealmObjectBase.freezeObject<YuukaDownPlatform>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(YuukaDownPlatform._);
    return const SchemaObject(
        ObjectType.realmObject, YuukaDownPlatform, 'YuukaDownPlatform', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('downloaderPlatform', RealmPropertyType.string),
      SchemaProperty('platformUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('jsonRPCVer', RealmPropertyType.string, optional: true),
      SchemaProperty('ariaToken', RealmPropertyType.string, optional: true),
    ]);
  }
}

class YuukaDownGalDB extends _YuukaDownGalDB
    with RealmEntity, RealmObjectBase, RealmObject {
  YuukaDownGalDB(
    ObjectId id,
    String galgameName, {
    String? downloadBaseUrl,
    String? partNum,
    String? fileType,
    String? subArea,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'galgameName', galgameName);
    RealmObjectBase.set(this, 'downloadBaseUrl', downloadBaseUrl);
    RealmObjectBase.set(this, 'partNum', partNum);
    RealmObjectBase.set(this, 'fileType', fileType);
    RealmObjectBase.set(this, 'subArea', subArea);
  }

  YuukaDownGalDB._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get galgameName =>
      RealmObjectBase.get<String>(this, 'galgameName') as String;
  @override
  set galgameName(String value) =>
      RealmObjectBase.set(this, 'galgameName', value);

  @override
  String? get downloadBaseUrl =>
      RealmObjectBase.get<String>(this, 'downloadBaseUrl') as String?;
  @override
  set downloadBaseUrl(String? value) =>
      RealmObjectBase.set(this, 'downloadBaseUrl', value);

  @override
  String? get partNum =>
      RealmObjectBase.get<String>(this, 'partNum') as String?;
  @override
  set partNum(String? value) => RealmObjectBase.set(this, 'partNum', value);

  @override
  String? get fileType =>
      RealmObjectBase.get<String>(this, 'fileType') as String?;
  @override
  set fileType(String? value) => RealmObjectBase.set(this, 'fileType', value);

  @override
  String? get subArea =>
      RealmObjectBase.get<String>(this, 'subArea') as String?;
  @override
  set subArea(String? value) => RealmObjectBase.set(this, 'subArea', value);

  @override
  Stream<RealmObjectChanges<YuukaDownGalDB>> get changes =>
      RealmObjectBase.getChanges<YuukaDownGalDB>(this);

  @override
  YuukaDownGalDB freeze() => RealmObjectBase.freezeObject<YuukaDownGalDB>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(YuukaDownGalDB._);
    return const SchemaObject(
        ObjectType.realmObject, YuukaDownGalDB, 'YuukaDownGalDB', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('galgameName', RealmPropertyType.string),
      SchemaProperty('downloadBaseUrl', RealmPropertyType.string,
          optional: true),
      SchemaProperty('partNum', RealmPropertyType.string, optional: true),
      SchemaProperty('fileType', RealmPropertyType.string, optional: true),
      SchemaProperty('subArea', RealmPropertyType.string, optional: true),
    ]);
  }
}
