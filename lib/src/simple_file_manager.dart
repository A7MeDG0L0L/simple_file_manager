part of simple_file_manager;

class SimpleFileManager extends StatefulWidget {
  /// List of Files that will shown
  final List<FileModel> filesList;

  /// Text for upload Button
  final String? uploadButtonText;

  final bool isWithUploadAndDownloadButtons;

  /// path for your placeholder to load if there is an exception in loading
  /// image
  final String? placeholderPath;

  /// callback for on Create folder button pressed
  final Future<String?> Function(String? parentID, String? folderName)?
      onCreateFolderClicked;

  /// callback for any folder pressed
  final Future<List<FileModel>?>? Function(FileModel? fileModel)?
      onFolderClicked;

  /// callback for any file pressed
  final void Function(FileModel? fileModel)? onFileClicked;

  /// callback for on item click download from dropdown menu button
  /// pressed
  final void Function(FileModel? fileModel)? onItemDownloadClicked;

  /// callback for on Create folder button pressed
  final Future<List<FileModel>?>? Function(String? previousParentId)? onBack;

  /// callback for on Upload button pressed
  final Future<List<String?>?>? Function(String? currentParentId,
      List<Uint8List?>? pickedFiles, List<String?>? pickedFilePaths)? onUpload;

  /// List for allowed Extensions to pick on click upload button
  final List<String>? allowedExtensionsToPick;

  /// if endpoint requires token to download photo
  final String? accessToken;

  /// Text for upload Button
  final String? downloadText;

  /// Text for CopyURL Button in dropdown menu when hold to open it on any file.
  final String? copyURLText;

  /// Text for Create folder Button.
  final String? createFolderText;

  /// Text for Create folder Button.
  final String? deleteSelectedButtonText;

  final List<DropdownMenuItem<String>>? dropdownItems;

  final Function(FileModel)? onItemSelected;

  final Future<bool> Function(List<String>)? onDeleteClicked;

  final bool supportDelete;

  const SimpleFileManager({
    Key? key,
    required this.filesList,
    this.uploadButtonText,
    this.placeholderPath,
    this.onCreateFolderClicked,
    this.onFolderClicked,
    this.onFileClicked,
    this.onItemDownloadClicked,
    this.onBack,
    this.onUpload,
    this.accessToken,
    this.downloadText,
    this.copyURLText,
    this.allowedExtensionsToPick,
    this.createFolderText,
    this.isWithUploadAndDownloadButtons = true,
    this.dropdownItems,
    this.onItemSelected,
    this.supportDelete = true,
    this.deleteSelectedButtonText,
    this.onDeleteClicked,
  }) : super(key: key);

  @override
  _SimpleFileManagerState createState() => _SimpleFileManagerState();
}

class _SimpleFileManagerState extends State<SimpleFileManager> {
  List<String>? _parentIds;
  List<FileModel>? _futureFiles;

  List<String>? _deletedIds;

  bool _loading = false;

  @override
  void initState() {
    _futureFiles = widget.filesList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                                            : _parentIds!.last);
                                    setState(() {
                                      _loading = false;
                                    });
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back)),
                    // const Spacer(),
                    if (widget.isWithUploadAndDownloadButtons)
                      Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onPressed: !_loading
                                  ? () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: widget
                                                      .allowedExtensionsToPick ??
                                                  [
                                                    'xlsx',
                                                    'jpeg',
                                                    'jpg',
                                                    'png',
                                                    'gif',
                                                    'pdf'
                                                  ],
                                              withData: true,
                                              allowMultiple: true);
                                      _loading = true;
                                      setState(() {});
                                      List<String?>? imageUrls =
                                          await widget.onUpload?.call(
                                              _parentIds == null ||
                                                      _parentIds!.length == 0
                                                  ? null
                                                  : _parentIds?.last,
                                              result?.files.first.bytes != null
                                                  ? result!.files
                                                      .map((e) => e.bytes)
                                                      .toList()
                                                  : null,
                                              result?.files.first.bytes != null
                                                  ? result!.files
                                                      .map((e) => e.name)
                                                      .toList()
                                                  : null);
                                      if (imageUrls != null) {
                                        for (String? imageUrl in imageUrls) {
                                          _futureFiles?.add(FileModel(
                                            name: result!.files.first.name,
                                            type: 'File',
                                            url: imageUrl,
                                            thumbnail: imageUrl,
                                            createdTime: DateTime.now(),
                                            fileExtension: result
                                                .files.first.name
                                                .split('.')
                                                .last,
                                          ));
                                        }
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
                                  Text(widget.uploadButtonText ?? 'Upload'),
                                ],
                              )),
                          const SizedBox(width: 20),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onPressed: !_loading
                                  ? () async {
                                      String? folderName;
                                      await showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: TextField(
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Enter Folder name ...'),
                                              onSubmitted: (String? value) {
                                                folderName = value;
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                      if (folderName != null &&
                                          folderName != '') {
                                        String? folderID = await widget
                                            .onCreateFolderClicked
                                            ?.call(
                                                _parentIds == null ||
                                                        (_parentIds?.isEmpty ??
                                                            false)
                                                    ? null
                                                    : _parentIds!.last,
                                                folderName);
                                        setState(() {
                                          if (folderID != null) {
                                            _futureFiles?.add(FileModel(
                                                id: folderID,
                                                // parent: Parent(id: _parentIds?.last),
                                                type: FileManagerTypes
                                                    .Folder.name,
                                                name: folderName));
                                            print(_futureFiles?.last.toJson());
                                          }
                                        });
                                      }
                                    }
                                  : null,
                              child: Row(
                                children: [
                                  const Icon(Icons.create_new_folder),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(widget.createFolderText ??
                                      'Create Folder'),
                                ],
                              )),
                          const SizedBox(width: 20),
                          if (widget.supportDelete)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor),
                                onPressed: ((!_loading) &&
                                        widget.supportDelete &&
                                        (_deletedIds?.isNotEmpty ?? false))
                                    ? () async {
                                        if (_deletedIds?.isNotEmpty ?? false) {
                                          _loading = true;
                                          setState(() {});
                                          bool? isDeleted = await widget
                                              .onDeleteClicked
                                              ?.call(_deletedIds!);
                                          if (isDeleted ?? false) {
                                            _futureFiles?.removeWhere(
                                                (element) => _deletedIds!.any(
                                                    (e) => e == element.id));
                                            _deletedIds = null;
                                            setState(() {});
                                          }
                                          _loading = false;
                                        }
                                      }
                                    : null,
                                child: Row(
                                  children: [
                                    const Icon(Icons.create_new_folder),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(widget.deleteSelectedButtonText ??
                                        'Delete selected'),
                                  ],
                                )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _futureFiles != null
                      ? Wrap(
                          children: <Widget>[
                            ..._futureFiles!.map((e) {
                              return CheckboxStack(
                                file: e,
                                // parentIds: _parentIds,
                                dropdownItems: widget.dropdownItems,
                                accessToken: widget.accessToken,
                                allowedExtensionsToPick:
                                    widget.allowedExtensionsToPick,
                                copyURLText: widget.copyURLText,
                                createFolderText: widget.createFolderText,
                                placeholderPath: widget.placeholderPath,
                                onUpload: (currentParentId, pickedFiles,
                                    pickedFilePaths) {},
                                onFolderClicked: (fileModel) async {
                                  print('FOLDER clicked ................');
                                  _parentIds ??= [];
                                  _parentIds?.add(e.id!);
                                  _loading = true;
                                  setState(() {});
                                  _futureFiles = await widget.onFolderClicked
                                      ?.call(fileModel);
                                  setState(() {
                                    _loading = false;
                                  });
                                  return;
                                },
                                onItemSelected: (p0) {
                                  widget.onItemSelected?.call(p0);
                                },
                                onItemSelectedForDelete: (file, checked) {
                                  _deletedIds ??= [];
                                  if (checked) {
                                    _deletedIds?.add(file.id!);
                                  } else {
                                    _deletedIds?.remove(file.id!);
                                  }
                                  setState(() {});
                                },
                              );
                            }),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
            ),
          )),
        ],
      ),
    );
  }
}
