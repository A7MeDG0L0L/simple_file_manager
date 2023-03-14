import 'dart:convert';

import 'package:flutter/material.dart';
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
    // _myData = await  getFilesData(null);
    setState(() {});
  }

  Future<List<FileModel>?>? _myData;

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

  Future uploadFile(String folderId) async {
    var response = http.MultipartRequest(
        "POST",
        Uri.parse('https://kafaratplus-api.tecfy'
            '.co/api/general/storage/file/admin')
        //     ,headers: {'Authorization': 'Bea'
        //     'rer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODAxMzQyOSwiZXhwIjoxNjc4MDk5ODI5fQ.N9ZwhteDr8ISX56VYpvUOW4_QG1G70mBL98Yu0eS5jg'},
        // body:
        );
    response.headers['Authorization'] = 'Bea'
        'rer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODAxMzQyOSwiZXhwIjoxNjc4MDk5ODI5fQ.N9ZwhteDr8ISX56VYpvUOW4_QG1G70mBL98Yu0eS5jg';
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
                onUpdate: (String? parentId) {},
                onCreateFolderClicked: (String? parentID) {},
                onBack: (String? value) async {
                  print(value);
                  _myData = await getFilesData(value);
                  setState(() {});
                },
                onFolderClicked: (value) async {
                  _myData = await getFilesData(value!.id);
                  return _myData;
                },
                placeholderFromAssets: 'assets/images/placeholder.png',
              ),
            // FutureBuilder(
            //   future: _myData,
            //   builder: (context, snapshot) {
            //     // if(snapshot.connectionState == ConnectionState.waiting){
            //     //   return Center(child: CircularProgressIndicator(),);
            //     // }
            //     // else
            //       if(snapshot.hasData) {
            //       return SimpleFileManager(
            //       filesList: snapshot.data!,
            //       uploadButton: 'Upload',
            //       // downloadButton: 'Download',
            //         onUpdate: (String? parentId){
            //
            //         },
            //       onCreateFolderClicked: (String? parentID){
            //
            //       },
            //         onBack: (String? value){
            //         print(value);
            //         _myData = getFilesData(value);
            //         setState(() {});
            //         },
            //         onFolderClicked: (value){
            //             _myData =  getFilesData(value!.id);
            //             return _myData;
            //
            //             },
            //       placeholderFromAssets: 'assets/images/placeholder.png',
            //       );
            //     } else
            //       return CircularProgressIndicator();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
