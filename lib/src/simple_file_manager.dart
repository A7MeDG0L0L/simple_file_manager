part of simple_file_manager;

class SimpleFileManager extends StatefulWidget {
  final List<FileModel> filesList;
  final String uploadButton;

  // final String downloadButton;
  final String placeholderFromAssets;
  final void Function(String? parentID)? onCreateFolderClicked;
  final Future<List<FileModel>> Function(FileModel? fileModel)? onFolderClicked;
  final void Function(FileModel? fileModel)? onFileClicked;
  final void Function(FileModel? fileModel)? onItemDownloadClicked;
  final void Function(String? previousParentId)? onBack;
  final void Function(String? previousParentId)? onUpdate;

  const SimpleFileManager(
      {Key? key,
      required this.filesList,
      required this.uploadButton,
      // required this.downloadButton,
      required this.placeholderFromAssets,
      this.onCreateFolderClicked,
      this.onFolderClicked,
      this.onFileClicked,
      this.onItemDownloadClicked,
      this.onBack,
      this.onUpdate})
      : super(key: key);

  @override
  _SimpleFileManagerState createState() => _SimpleFileManagerState();
}

class _SimpleFileManagerState extends State<SimpleFileManager> {
  List<String>? _parentIds;
  Future<List<FileModel>>? futureFiles;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_parentIds?.isNotEmpty ?? false)
                    IconButton(
                        onPressed: () {
                          if (_parentIds != null) {
                            print(_parentIds);
                            print(_parentIds!.length);
                            widget.onBack?.call(_parentIds!.length > 1
                                ? _parentIds
                                    ?.elementAt((_parentIds!.length - 2))
                                : null);
                            _parentIds?.removeLast();
                          }
                        },
                        icon: const Icon(Icons.arrow_back)),
                  const Spacer(),

                  ElevatedButton(
                      onPressed: () {
                        widget.onUpdate?.call(_parentIds?.last);
                      },
                      child: Text(widget.uploadButton)),
                  const SizedBox(width: 20),
                  // ElevatedButton(
                  //     onPressed: (){},
                  //     child:  Text(widget.downloadButton)),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () async {
                        String? folderName;
                        await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Enter Folder name ...'),
                                onSubmitted: (String? value) {
                                  folderName = value;
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                        if (folderName != null && folderName != '') {
                          print(folderName);
                          widget.filesList.add(FileModel(
                              type: FileManagerTypes.Folder.name,
                              name: folderName));
                          widget.onCreateFolderClicked?.call('');
                          setState(() {});
                        }
                      },
                      child: const Text('Create Folder')),
                ],
              ),
            ),
            Wrap(
              children: <Widget>[
                ...widget.filesList.map((e) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: () {
                        if (e.type == FileManagerTypes.Folder.name) {
                          _parentIds ??= [];
                          _parentIds?.add(e.id!);
                          print(_parentIds);
                          futureFiles = widget.onFolderClicked?.call(e);
                          setState(() {});
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          if (e.type == FileManagerTypes.Folder.name)
                            const Icon(Icons.folder,
                                color: Colors.blue, size: 100),
                          if (e.type == FileManagerTypes.File.name)
                            e.thumbnail != null
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      openWithLongPress: true,
                                      isExpanded: true,
                                      onChanged: (v) {
                                        print(v);
                                      },
                                      onMenuStateChange: (bool value) {
                                        print(value);
                                      },
                                      dropdownStyleData: DropdownStyleData(
                                        width: 160,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        elevation: 8,
                                        offset: const Offset(40, -4),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          onTap: () async {
                                            print('download button pressed');
                                            WidgetsFlutterBinding
                                                .ensureInitialized();
                                            try {
                                              final downloaderUtils =
                                                  DownloaderUtils(
                                                progressCallback:
                                                    (current, total) {
                                                  final progress =
                                                      (current / total) * 100;
                                                  print(
                                                      'Downloading: $progress');
                                                },
                                                file: File('Downloads/${e.name}'
                                                    '.${e.fileExtension}'),
                                                progress:
                                                    ProgressImplementation(),
                                                onDone: () =>
                                                    print('Download done'),
                                                deleteOnCancel: true,
                                                accessToken:
                                                    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMmFkMTE2Yjk4NTJlYTRmYjI5ZTgwNCIsIm5hbWUiOiJ7XCJhclwiOlwi2YXYrdmF2K9cIixcImVuXCI6XCJNb2hhbW1lZFwifSIsInR5cGUiOiJhZG1pbiIsInNlY3VyaXR5R3JvdXBJZCI6IjYzZWUwY2ZlZjc3YzIzZWVlZWExZmQ0MiIsImlhdCI6MTY3ODAxMzQyOSwiZXhwIjoxNjc4MDk5ODI5fQ.N9ZwhteDr8ISX56VYpvUOW4_QG1G70mBL98Yu0eS5jg',
                                              );

                                              final core =
                                                  await Flowder.download(
                                                      e.url!, downloaderUtils);
                                            } catch (e, st) {
                                              print(e);
                                              print(st);
                                            }
                                          },
                                          value: 'Download',
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.download,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Download',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          onTap: () async {
                                            await Clipboard.setData(
                                                ClipboardData(text: e.url));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text('URL Copied'),
                                              backgroundColor: Colors.green,
                                            ));
                                          },
                                          value: 'Copy',
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.copy,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Copy URL',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                      customButton: Image.network(
                                        e.thumbnail!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  )
                                : Image.asset(widget.placeholderFromAssets,
                                    width: 100, fit: BoxFit.fitHeight),
                          Text(e.name ?? ''),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
