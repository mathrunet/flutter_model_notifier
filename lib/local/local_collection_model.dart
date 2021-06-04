part of model_notifier;

/// Base class for holding and manipulating data from a local database as a collection of [LocalDocumentModel].
///
/// The [load()] method retrieves the value from the local database and
/// the [save()] method saves the value to the local database.
///
/// The local database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [List],
/// it is possible to operate the content as it is.
abstract class LocalCollectionModel<T extends LocalDocumentModel>
    extends ListModel<T>
    implements
        StoredModel<List<T>, LocalCollectionModel<T>>,
        CollectionMockModel<T, LocalCollectionModel<T>> {
  /// Base class for holding and manipulating data from a local database as a collection of [LocalDocumentModel].
  ///
  /// The [load()] method retrieves the value from the local database and
  /// the [save()] method saves the value to the local database.
  ///
  /// The local database is a Json database.
  /// Specify a path to specify the location of the contents.
  ///
  /// In addition, since it can be used as [List],
  /// it is possible to operate the content as it is.
  LocalCollectionModel(this.path, [List<T>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(value ?? []) {
    _LocalDatabase._registerParent(this);
  }

  /// The method to be executed when initialization is performed.
  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isEnabledMockup) {
      if (isNotEmpty) {
        return;
      }
      if (initialMock.isNotEmpty) {
        addAll(initialMock);
      }
    }
  }

  /// Initial value of mock.
  @override
  @protected
  final List<T> initialMock = const [];

  /// If this value is true,
  /// Notify changes when there are changes in the list itself using list-specific methods.
  @override
  bool get notifyOnChangeList => false;

  /// If this value is true,
  /// the change will be notified when [value] itself is changed.
  @override
  bool get notifyOnChangeValue => true;

  /// Discards any resources used by the object.
  /// After this is called, the object is not in a usable state and should be discarded (calls to [addListener] and [removeListener] will throw after the object is disposed).
  ///
  /// This method should only be called by the object's owner.
  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _LocalDatabase._unregisterParent(this);
  }

  /// Path of the local database.
  final String path;

  /// Returns itself after the load finishes.
  @override
  Future<LocalCollectionModel<T>> get loading =>
      _loadingCompleter?.future ?? Future.value(this);
  Completer<LocalCollectionModel<T>>? _loadingCompleter;

  /// Returns itself after the save finishes.
  @override
  Future<LocalCollectionModel<T>> get saving => throw UnimplementedError(
      "Save process should be done for each document.");

  /// Callback before the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  /// Callback after the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  /// Callback after the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onSave() async => throw UnimplementedError(
      "Save process should be done for each document.");

  /// Callback after the save has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onDidSave() async => throw UnimplementedError(
      "Save process should be done for each document.");

  /// Add a process to create a document object.
  @protected
  T createDocument(String path);

  /// Create a new document.
  ///
  /// [id] is the ID of the document. If it is blank, [uuid] is used.
  T create([String? id]) => createDocument("$path/${id.isEmpty ? uuid : id}");

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  LocalCollectionModel<T> mock(List<T> mockDataList) {
    if (!Config.isEnabledMockup) {
      return this;
    }
    if (isNotEmpty) {
      return this;
    }
    if (mockDataList.isNotEmpty) {
      addAll(mockDataList);
      notifyListeners();
    }
    return this;
  }

  /// Retrieves data and updates the data in the model.
  ///
  /// You will be notified of model updates at the time they are retrieved.
  ///
  /// In addition,
  /// the updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<LocalCollectionModel<T>> load() async {
    if (_loadingCompleter != null) {
      return loading;
    }
    _loadingCompleter = Completer<LocalCollectionModel<T>>();
    try {
      await _LocalDatabase.initialize();
      await onLoad();
      bool notify = false;
      final data = _LocalDatabase._root._readFromPath<DynamicMap?>(path);
      if (isNotEmpty) {
        clear();
        notify = true;
      }
      if (data.isNotEmpty) {
        notify = true;
        final addData = <T>[];
        for (final tmp in data!.entries) {
          if (tmp.key.isEmpty || tmp.value is! DynamicMap) {
            continue;
          }
          final value = createDocument("$path/${tmp.key}");
          value.value = value.fromMap(value.filterOnLoad(tmp.value));
          addData.add(value);
        }
        addAll(addData);
      }
      if (notify) {
        notifyListeners();
      }
      await onDidLoad();
      _loadingCompleter?.complete(this);
      _loadingCompleter = null;
    } catch (e) {
      _loadingCompleter?.completeError(e);
      _loadingCompleter = null;
      rethrow;
    }
    return this;
  }

  /// Data stored in the model is stored in a database external to the app that is tied to the model.
  ///
  /// The updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<LocalCollectionModel<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<LocalCollectionModel<T>> reload() => load();

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<LocalCollectionModel<T>> loadOnce() async {
    if (isEmpty) {
      return load();
    }
    return this;
  }

  void _addChildInternal(T document) {
    if (any((e) => e == document || e.path == document.path)) {
      return;
    }
    add(document);
    notifyListeners();
  }

  void _removeChildInternal(T document) {
    if (!any((e) => e == document || e.path == document.path)) {
      return;
    }
    remove(document);
    notifyListeners();
  }

  // void _notifyChildChanges() {
  //   notifyListeners();
  // }
}
