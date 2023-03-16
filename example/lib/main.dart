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
    // getFilesData();
    init();

    super.initState();
  }

  init() async {
    _myData = await getFilesData(null);
    setState(() {});
  }

  List<FileModel>? _myData;

  Future<List<FileModel>?> getFilesData(String? parentId) async {
    print('Getting Files Data');
    var response = await http.get(
        Uri.parse('https://kafaratplus-api.tecfy'
            '.co/api/admin/setup/file/tree?parentId=${parentId ?? ''}&skip=0'
            '&count=0'),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODAxMzQyOSwiZXhwIjoxNjc4MDk5ODI5fQ.N9ZwhteDr8ISX56VYpvUOW4_QG1G70mBL98Yu0eS5jg'
        });
    print(response.statusCode);
    print(response.request?.url);
    Map<String, dynamic> json = jsonDecode(response.body);

    return List<FileModel>.from(json['data'].map((e) => FileModel.fromJson(e)));
  }

  Future<String> uploadFile(
      String? folderId, Uint8List? pickedFile, String? pickedFileName) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse('https://kafaratplus-api.tecfy'
            '.co/api/general/storage/folder/file/admin')
        //     ,headers: {'Authorization': 'Bea'
        //     'rer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODAxMzQyOSwiZXhwIjoxNjc4MDk5ODI5fQ.N9ZwhteDr8ISX56VYpvUOW4_QG1G70mBL98Yu0eS5jg'},
        // body:
        );
    request.headers['Authorization'] = 'Bea'
        'rer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODg3NzU2NCwiZXhwIjoxNjc4OTYzOTY0fQ.ICcIYzGcYNC7NoHLyccmNsSkYJsVdVxN6qRMnLo_ceo';

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
    print(response.statusCode);
    print(r);
    return r['data']['thumbnailUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_myData != null)
              SimpleFileManager(
                filesList: _myData!,
                uploadButton: 'Upload',
                // downloadButton: 'Download',
                onUpload: (String? parentId, pickedFile,
                    String? pickedFileName) async {
                  print(pickedFileName);
                  print(parentId);
                  if (pickedFile != null) {
                    return await uploadFile(
                        parentId, pickedFile, pickedFileName);
                  } else {
                    return null;
                  }
                },
                onCreateFolderClicked: (String? parentID) {},
                onBack: (String? value) async {
                  print(value);
                  return await getFilesData(value);
                },
                onFolderClicked: (value) async {
                  return await getFilesData(value!.id);
                  // return _myData;
                },
                placeholderFromAssets: 'assets/images/placeholder.png',
              ),
          ],
        ),
      ),
    );
  }
}
