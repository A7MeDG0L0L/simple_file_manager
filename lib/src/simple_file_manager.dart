part of simple_file_manager;

class SimpleFileManager extends StatefulWidget {
  final List<FileModel> filesList;
  final String uploadButton;

  // final String downloadButton;
  final String placeholderFromAssets;
  final void Function(String? parentID)? onCreateFolderClicked;
  final Future<List<FileModel>?>? Function(FileModel? fileModel)?
      onFolderClicked;
  final void Function(FileModel? fileModel)? onFileClicked;
  final void Function(FileModel? fileModel)? onItemDownloadClicked;
  final Future<List<FileModel>?>? Function(String? previousParentId)? onBack;
  final Future<bool> Function(String? previousParentId, Uint8List? pickedFile,
      String? pickedFilePath)? onUpload;

  /// if endpoint requires token to download photo
  final String? accessToken;
  final String? downloadText;
  final String? copyURLText;

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
      this.onUpload,
      this.accessToken,
      this.downloadText,
      this.copyURLText})
      : super(key: key);

  @override
  _SimpleFileManagerState createState() => _SimpleFileManagerState();
}

class _SimpleFileManagerState extends State<SimpleFileManager> {
  List<String>? _parentIds;
  List<FileModel>? _futureFiles;

  bool _loading = false;

  @override
  void initState() {
    _futureFiles = widget.filesList;

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
                        onPressed: !_loading
                            ? () async {
                                if (_parentIds != null) {
                                  _parentIds?.removeLast();
                                  _loading = true;
                                  setState(() {});

                                  _futureFiles = await widget.onBack?.call(
                                      _parentIds == null ||
                                              (_parentIds?.isEmpty ?? false)
                                          ? null
                                          : _parentIds!.last
                                      );
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back)),
                  const Spacer(),

                  ElevatedButton(
                      onPressed: !_loading
                          ? () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        'xlsx',
                                        'jpeg',
                                        'jpg',
                                        'png',
                                        'gif'
                                      ],
                                      withData: true);
                              _loading = true;
                              setState(() {});
                              bool? response = await widget.onUpload?.call(
                                  _parentIds == null || _parentIds!.length == 0
                                      ? null
                                      : _parentIds?.last,
                                  result?.files.first.bytes != null
                                      ? result!.files.first.bytes
                                      : null,
                                  result?.files.first.bytes != null
                                      ? result!.files.first.name
                                      : null);
                              if (response ?? false) {
                                _futureFiles?.add(FileModel(
                                  name: result!.files.first.name,
                                  type: 'File',
                                  createdTime: DateTime.now(),
                                  fileExtension:
                                      result.files.first.name.split('.').last,
                                ));
                              }
                              _loading = false;
                              setState(() {});
                            }
                          : null,
                      child: Row(
                        children: [
                          const Icon(Icons.upload),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(widget.uploadButton),
                        ],
                      )),
                  const SizedBox(width: 20),
                  // ElevatedButton(
                  //     onPressed: (){},
                  //     child:  Text(widget.downloadButton)),
                  ElevatedButton(
                      onPressed: !_loading
                          ? () async {
                              String? folderName;
                              await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      autofocus: true,
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
                                _futureFiles?.add(FileModel(
                                    type: FileManagerTypes.Folder.name,
                                    name: folderName));
                                widget.onCreateFolderClicked?.call(
                                    _parentIds == null ||
                                            (_parentIds?.isEmpty ?? false)
                                        ? null
                                        : _parentIds!.last);
                                setState(() {});
                              }
                            }
                          : null,
                      child: Row(
                        children: const [
                          Icon(Icons.create_new_folder),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Create Folder'),
                        ],
                      )),
                ],
              ),
            ),
            if (_futureFiles != null)
              _loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Wrap(
                      children: <Widget>[
                        ..._futureFiles!.map((e) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: InkWell(
                              onTap: () async {
                                if (e.type == FileManagerTypes.Folder.name) {
                                  _parentIds ??= [];
                                  _parentIds?.add(e.id!);
                                  _loading = true;
                                  setState(() {});
                                  _futureFiles =
                                      await widget.onFolderClicked?.call(e);
                                  _loading = false;
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
                                              onChanged: (v) {},
                                              onMenuStateChange:
                                                  (bool value) {},
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                width: 160,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                elevation: 8,
                                                offset: const Offset(40, -4),
                                              ),
                                              items: [
                                                DropdownMenuItem(
                                                  onTap: () async {
                                                    debugPrint(
                                                        'download button pressed');
                                                    WidgetsFlutterBinding
                                                        .ensureInitialized();
                                                    try {
                                                      Directory
                                                          appDocDirectory =
                                                          await getApplicationDocumentsDirectory();

                                                      final downloaderUtils =
                                                          DownloaderUtils(
                                                        progressCallback:
                                                            (current, total) {
                                                          final progress =
                                                              (current /
                                                                      total) *
                                                                  100;
                                                          debugPrint(
                                                              'Downloading: $progress');
                                                        },
                                                        file: File(
                                                            '${appDocDirectory.path}/${e.name}'
                                                            '.${e.fileExtension}'),
                                                        progress:
                                                            ProgressImplementation(),
                                                        onDone: () {
                                                          debugPrint(
                                                              'Download done');
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            content: Text(
                                                                'Download '
                                                                'Completed'),
                                                            backgroundColor:
                                                                Colors.green,
                                                          ));
                                                        },
                                                        deleteOnCancel: true,
                                                        accessToken:
                                                            'Bearer ${widget.accessToken}',
                                                      );
                                                      debugPrint(
                                                          '${appDocDirectory.path}/${e.name}');
                                                      final core = await Flowder
                                                          .download(e.url!,
                                                              downloaderUtils);
                                                    } catch (e, st) {
                                                      debugPrint("$e");
                                                      debugPrint("$st");
                                                    }
                                                  },
                                                  value: 'Download',
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.download,
                                                        color: Colors.white,
                                                        size: 22,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        widget.downloadText ??
                                                            ''
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
                                                        ClipboardData(
                                                            text: e.url));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                      content:
                                                          Text('URL Copied'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ));
                                                  },
                                                  value: 'Copy',
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.copy,
                                                        color: Colors.white,
                                                        size: 22,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        widget.copyURLText ??
                                                            'Copy URL',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                              customButton:
                                                  FadeInImage.assetNetwork(
                                                imageErrorBuilder: (context,
                                                    error, stackTrace) {
                                                  return Image.asset(
                                                      widget
                                                          .placeholderFromAssets,
                                                      width: 100,
                                                      fit: BoxFit.fitHeight);
                                                },
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.fitHeight,
                                                placeholder: widget
                                                    .placeholderFromAssets,
                                                image: e.thumbnail!,
                                              ),
                                            ),
                                          )
                                        : Image.asset(
                                            widget.placeholderFromAssets,
                                            width: 100,
                                            fit: BoxFit.fitHeight),
                                  SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          e.name ?? '',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
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
