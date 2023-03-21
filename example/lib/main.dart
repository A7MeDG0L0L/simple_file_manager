import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:simple_file_manager/simple_file_manager.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple File Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple File Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    init();

    super.initState();
  }

  init() async {
    _myData = await getFilesData(null);
    setState(() {});
  }

  List<FileModel>? _myData;

  /// Get url data using api or anyway you want
  Future<List<FileModel>?> getFilesData(String? parentId) async {
    var response = await http.get(
        Uri.parse(
          'https://kafaratplus-api.tecfy.co/api/admin/setup/file/tree?parentId=${parentId ?? ''}&skip=0'
          '&count=0'),
       );
    Map<String, dynamic> json = jsonDecode(response.body);
    return List<FileModel>.from(json['data'].map((e) => FileModel.fromJson(e)));
  }

  Future<String> uploadFile(
      String? folderId, Uint8List? pickedFile, String? pickedFileName) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse('yourBaseUrl.api/storage/folder/file/admin'));
       request.files.add(http.MultipartFile.fromBytes(
      'file',
      pickedFile!,
      filename: pickedFileName,
      contentType: MediaType("image", pickedFileName!.split('.').last),
    ));
    request.fields['name'] = pickedFileName;
    request.headers["Content-Type"] = "image/jpg";
    request.fields['path'] = 'img';
    request.fields['type'] = 'File';
    request.fields['parentId'] = folderId!;

    var response = await request.send();
    var data = await response.stream.toBytes();
    String dataString = utf8.decode(data);
    var r = json.decode(dataString);
    return r['data']['thumbnailUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _myData != null
          ? SimpleFileManager(
              filesList: _myData!,
              uploadButtonText: 'Upload',
              onUpload:
                  (String? parentId, pickedFile, String? pickedFileName) async {
                if (pickedFile != null) {
                  return await uploadFile(parentId, pickedFile, pickedFileName);
                } else {
                  return null;
                }
              },
              // onCreateFolderClicked: (String? parentID,String? folderName) {
              // },
              onBack: (String? value) async {
                return await getFilesData(value);
              },
              onFolderClicked: (value) async {
                return await getFilesData(value!.id);
              },
              // placeholderFromAssets: 'assets/images/placeholder.png',
            )
          : null,
    );
  }
}
