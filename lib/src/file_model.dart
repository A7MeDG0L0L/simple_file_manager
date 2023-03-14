part of simple_file_manager;

// To parse this JSON data, do
//
//     final fileModel = fileModelFromJson(jsonString);

FileModel fileModelFromJson(String str) => FileModel.fromJson(json.decode(str));

String fileModelToJson(FileModel data) => json.encode(data.toJson());

class FileModel {
  FileModel({
    this.id,
    this.name,
    this.url,
    this.thumbnail,
    this.fileSize,
    this.parent,
    this.type,
    this.createdTime,
    this.updatedTime,
    this.fileExtension,
  });

  String? id;
  String? name;
  String? url;
  String? thumbnail;
  int? fileSize;
  Parent? parent;
  String? type;
  DateTime? createdTime;
  DateTime? updatedTime;
  String? fileExtension;

  factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
        id: json["_id"],
        name: json["name"],
        url: json["url"],
        thumbnail: json["thumbnail"],
        fileSize: json["fileSize"],
        parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
        type: json["type"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
        updatedTime: json["updatedTime"] == null
            ? null
            : DateTime.parse(json["updatedTime"]),
        fileExtension: json["fileExtension"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "url": url,
        "thumbnail": thumbnail,
        "fileSize": fileSize,
        "parent": parent?.toJson(),
        "type": type,
        "createdTime": createdTime?.toIso8601String(),
        "updatedTime": updatedTime?.toIso8601String(),
        "fileExtension": fileExtension,
      };
}

class Parent {
  Parent({
    this.id,
    this.name,
    this.parent,
    this.type,
    this.createdTime,
    this.updatedTime,
  });

  String? id;
  String? name;
  Parent? parent;
  String? type;
  DateTime? createdTime;
  DateTime? updatedTime;

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        id: json["_id"],
        name: json["name"],
        parent: json["parent"],
        type: json["type"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]),
        updatedTime: json["updatedTime"] == null
            ? null
            : DateTime.parse(json["updatedTime"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "parent": parent,
        "type": type,
        "createdTime": createdTime?.toIso8601String(),
        "updatedTime": updatedTime?.toIso8601String(),
      };
}
