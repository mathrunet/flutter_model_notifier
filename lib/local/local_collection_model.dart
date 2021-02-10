part of model_notifier;

abstract class LocalCollectionModel<T extends LocalDocumentModel>
    extends ListModel<T> implements StoredModel<List<T>> {
  LocalCollectionModel(this.path, [List<T> value = const []])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(value) {
    _LocalDatabase._registerParent(this);
  }

  @override
  bool get notifyOnChangeList => false;

  @override
  bool get notifyOnChangeValue => true;

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _LocalDatabase._unregisterParent(this);
  }

  final String path;

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  T createDocument(String path);

  T create([String? id]) =>
      createDocument("$path/${id == null || id.isEmpty ? uuid : id}");

  @override
  Future<List<T>> load() async {
    await _LocalDatabase.initialize();
    await onLoad();
    bool notify = false;
    final data = _LocalDatabase._root._readFromPath(path);
    if (isNotEmpty) {
      clear();
      notify = true;
    }
    if (data != null) {
      final addData = <T>[];
      for (final tmp in data.entries) {
        if (tmp.key.isEmpty || tmp.value is! Map<String, dynamic>) {
          continue;
        }
        final value = createDocument("$path/${tmp.key}");
        value.value = value.fromMap(value.filterOnLoad(tmp.value));
        addData.add(value);
      }
      addAll(addData);
    }
    if (notify) {
      streamController.sink.add(value);
      notifyListeners();
    }
    await onDidLoad();
    return this;
  }

  @override
  Future<List<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  void _addChildInternal(T document) {
    if (any((e) => e == document || e.path == document.path)) {
      return;
    }
    add(document);
    streamController.sink.add(value);
    notifyListeners();
  }

  void _removeChildInternal(T document) {
    if (!any((e) => e == document || e.path == document.path)) {
      return;
    }
    remove(document);
    streamController.sink.add(value);
    notifyListeners();
  }

  void _notifyChildChanges() {
    streamController.sink.add(value);
    notifyListeners();
  }
}
