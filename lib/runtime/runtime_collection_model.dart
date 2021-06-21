part of model_notifier;

/// Base class for holding and manipulating data from a runtime database as a collection of [RuntimeDocumentModel].
///
/// The runtime database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [List],
/// it is possible to operate the content as it is.
abstract class RuntimeCollectionModel<T extends RuntimeDocumentModel>
    extends ListModel<T>
    implements
        StoredModel<List<T>, RuntimeCollectionModel<T>>,
        CollectionMockModel<T, RuntimeCollectionModel<T>> {
  /// Base class for holding and manipulating data from a runtime database as a collection of [RuntimeDocumentModel].
  ///
  /// The runtime database is a Json database.
  /// Specify a path to specify the location of the contents.
  ///
  /// In addition, since it can be used as [List],
  /// it is possible to operate the content as it is.
  RuntimeCollectionModel(String path, [List<T>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        path = path.trimQuery(),
        parameters = _getParameters(path),
        super(value ?? []);

  static Map<String, String> _getParameters(String path) {
    if (path.contains("?")) {
      return Uri.parse(path).queryParameters;
    }
    return const {};
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

  /// Discards any resources used by the object.
  /// After this is called, the object is not in a usable state and should be discarded (calls to [addListener] and [removeListener] will throw after the object is disposed).
  ///
  /// This method should only be called by the object's owner.
  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    RuntimeDatabase._db.removeCollectionListener(_query);
  }

  _LocalStoreCollectionQuery? _query;

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
  bool get notifyOnChangeValue => false;

  /// If this value is `true`,
  /// you will be notified when the element has been modified.
  bool get notifyOnModified => _notifyOnModified;
  // ignore: prefer_final_fields
  bool _notifyOnModified = false;

  /// Change the value of [notifyOnModified] to [notify].
  void setNotifyOnModified(bool notify) {
    _notifyOnModified = notify;
  }

  /// Path of the runtime database.
  final String path;

  /// Parameters of the runtime database.
  final Map<String, String> parameters;

  /// Returns itself after the load/save finishes.
  @override
  Future<void> get future => _completer?.future ?? Future.value();
  Completer<void>? _completer;

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
  T create([String? id]) =>
      createDocument("${path.trimQuery()}/${id.isEmpty ? uuid : id}");

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  RuntimeCollectionModel<T> mock(List<T> mockDataList) {
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
  Future<RuntimeCollectionModel<T>> load() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    try {
      await onLoad();
      bool notify = false;
      _query ??= _LocalStoreCollectionQuery(
        path: path,
        callback: _handledOnUpdate,
        filter: parameters.isEmpty
            ? null
            : (data) => CollectionQuery._filter(parameters, data),
        origin: this,
      );
      RuntimeDatabase._db.addCollectionListener(_query!);
      final data = await RuntimeDatabase._db.loadCollection(_query!);
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
          final value = createDocument("${path.trimQuery()}/${tmp.key}");
          value.value = value.fromMap(value.filterOnLoad(tmp.value));
          addData.add(value);
        }
        addAll(addData);
      }
      if (notify) {
        notifyListeners();
      }
      await onDidLoad();
      _completer?.complete();
      _completer = null;
    } finally {
      _completer?.completeError(e);
      _completer = null;
    }
    return this;
  }

  void _handledOnUpdate(_LocalStoreDocumentUpdate update) {
    switch (update.status) {
      case _LocalStoreDocumentUpdateStatus.deleted:
        removeWhere((element) =>
            element.path.trimQuery().trimString("/") == update.path);
        break;
      default:
        final found = firstWhereOrNull((element) =>
            element.path.trimQuery().trimString("/") == update.path);
        if (found != null) {
          if (found == update.origin) {
            return;
          }
          found.value = found.fromMap(found.filterOnLoad(update.value));
        } else {
          final value = createDocument("${path.trimQuery()}/${update.id}");
          value.value = value.fromMap(value.filterOnLoad(update.value));
          add(value);
        }
        break;
    }
  }

  /// Data stored in the model is stored in a database external to the app that is tied to the model.
  ///
  /// The updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<RuntimeCollectionModel<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<RuntimeCollectionModel<T>> reload() async {
    clear();
    await load();
    return this;
  }

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<RuntimeCollectionModel<T>> loadOnce() async {
    if (isEmpty) {
      return load();
    }
    return this;
  }
}
