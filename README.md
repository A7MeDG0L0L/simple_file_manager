
![Logo](https://github.com/A7MeDG0L0L/simple_file_manager/blob/main/Simple%20File%20Manager.jpg)


# Simple File Manager

A Simple file manager which can preview folders and file in simple way and download files from it.



## Features

- List folders and files
- Preview files
- Upload new files
- Create new folders
- Download file
- copy file URL
- Zoom in/out in Image files



## Demo

<img src="https://github.com/A7MeDG0L0L/simple_file_manager/blob/main/demo.gif">

## Usage/Examples
Follow below example

```dart
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
        Uri.parse('yourBaseUrl.api/file/tree?parentId=${parentId ?? ''}&skip=0'
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
                uploadButtonText: 'Upload',
                onUpload: (String? parentId, pickedFile,
                    String? pickedFileName) async {
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
                },
                placeholderFromAssets: 'assets/images/placeholder.png',
              ),
          ],
        ),
      ),
    );
  }
}
```


## Authors

- [Ahmed Galal](https://www.linkedin.com/in/a7medg0l0l)


## Contributing

Contributions are always welcome!




## Feedback

If you have any feedback, please reach out to me at agalal819@gmail.com

