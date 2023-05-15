part of simple_file_manager;

class CheckboxStack extends StatefulWidget {
  final FileModel file;

  // List<String>? parentIds;
  final String? placeholderPath;

  /// callback for on Create folder button pressed
  final Future<String?> Function(String? parentID, String? folderName)?
      onCreateFolderClicked;

  /// callback for any folder pressed
  final void Function(FileModel? fileModel)? onFolderClicked;

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

  final List<DropdownMenuItem<String>>? dropdownItems;

  final Function(FileModel)? onItemSelected;
  final Function(FileModel, bool checked)? onItemSelectedForDelete;

  const CheckboxStack(
      {Key? key,
      required this.file,
      this.placeholderPath,
      this.onCreateFolderClicked,
      this.onFolderClicked,
      this.onFileClicked,
      this.onItemDownloadClicked,
      this.onBack,
      this.onUpload,
      this.allowedExtensionsToPick,
      this.accessToken,
      this.downloadText,
      this.copyURLText,
      this.createFolderText,
      this.dropdownItems,
      this.onItemSelected,
      this.onItemSelectedForDelete})
      : super(key: key);

  @override
  _CheckboxStackState createState() => _CheckboxStackState();
}

class _CheckboxStackState extends State<CheckboxStack> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.file.type == FileManagerTypes.Folder.name) {
          widget.onFolderClicked?.call(widget.file);
          setState(() {});
        }
      },
      onDoubleTap: () async {
        if (widget.file.type == FileManagerTypes.Folder.name) {
          widget.onFolderClicked?.call(widget.file);
          setState(() {});
        }
        if (widget.file.type == FileManagerTypes.File.name) {
          await FileViewUtils.viewFile(
              UploadData(name: widget.file.name, url: widget.file.url),
              context,
              Theme.of(context).primaryColor);
        }
      },
      onLongPress: () {
        _isChecked = !_isChecked;
        widget.onItemSelectedForDelete?.call(widget.file, _isChecked);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: _isChecked
                  ? Border.all(width: 1.2, color: Colors.black)
                  : null,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  if (widget.file.type == FileManagerTypes.Folder.name)
                    folderWidget(),
                  if (widget.file.type == FileManagerTypes.File.name)
                    fileWidget(widget.file),
                  SizedBox(
                      width: 100,
                      child: Center(
                        child: Text(
                          widget.file.name ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                ],
              ),
              if (_isChecked) Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget folderWidget() {
    return Icon(Icons.folder, color: Theme.of(context).primaryColor, size: 100);
  }

  Widget fileWidget(FileModel e) {
    return e.thumbnail != null
        ? DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              onMenuStateChange: (value) {},
              onChanged: (String? selectedItem) {
                if (selectedItem != null) widget.onItemSelected?.call(e);
              },
              isExpanded: true,
              dropdownStyleData: DropdownStyleData(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).primaryColor,
                ),
                elevation: 8,
                offset: const Offset(40, -4),
              ),
              items: [
                ...?widget.dropdownItems,
                DropdownMenuItem(
                  onTap: () async {
                    debugPrint('download button pressed');
                    WidgetsFlutterBinding.ensureInitialized();
                    try {
                      String? appDocDirectory = await getDownloadPath();

                      final downloaderUtils = DownloaderUtils(
                        progressCallback: (current, total) {
                          final progress = (current / total) * 100;
                          debugPrint('Downloading: $progress');
                        },
                        file: File('$appDocDirectory'
                            '/${e.name}'),
                        progress: ProgressImplementation(),
                        onDone: () {
                          debugPrint('Download done');
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Download '
                                'Completed'),
                            backgroundColor: Colors.green,
                          ));
                        },
                        deleteOnCancel: true,
                        accessToken: 'Bearer ${widget.accessToken}',
                      );
                      debugPrint('$appDocDirectory/${e.name}');
                      await Flowder.download(e.url!, downloaderUtils);
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
                    await Clipboard.setData(ClipboardData(text: e.url ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('URL Copied'),
                      backgroundColor: Colors.green,
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
                        widget.copyURLText ?? 'Copy URL',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              customButton: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                        widget.placeholderPath ??
                            'packages/sim'
                                'ple_file'
                                '_manager'
                                '/assets/images/placeholder.png',
                        width: 100,
                        fit: BoxFit.fitHeight);
                  },
                  width: 100,
                  height: 100,
                  fit: BoxFit.fitHeight,
                  placeholder: widget.placeholderPath ??
                      'packages/sim'
                          'ple_file'
                          '_manager'
                          '/assets/images/placeholder.png',
                  image: e.thumbnail!,
                ),
              ),
            ),
          )
        : Image.asset(
            widget.placeholderPath ??
                'packages/sim'
                    'ple_file'
                    '_manager'
                    '/assets/images/placeholder.png',
            width: 100,
            fit: BoxFit.fitHeight);
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (!Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      debugPrint("Cannot get download folder path");
    }
    return directory?.path;
  }
}
