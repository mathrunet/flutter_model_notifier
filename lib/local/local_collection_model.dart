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
  LocalCollectionModel(String path, [List<T>? value])
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

  /// If this value is `true`,
  /// you will be notified when the element has been modified.
  bool get notifyOnModified => _notifyOnModified;
  // ignore: prefer_final_fields
  bool _notifyOnModified = false;

  /// Change the value of [notifyOnModified] to [notify].
  void setNotifyOnModified(bool notify) {
    _notifyOnModified = notify;
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
    LocalDatabase._db.removeCollectionListener(_query);
  }

  _LocalStoreCollectionQuery? _query;
  List<MapEntry<String, Map<String, dynamic>>> _rawEntries = [];

  /// Path of the local database.
  final String path;

  /// Parameters of the local database.
  final Map<String, String> parameters;

  /// Returns itself after the load/save finishes.
  @override
  Future<void>? get future => _completer?.future;
  Completer<void>? _completer;

  /// It becomes `true` after [loadOnce] is executed.
  @override
  bool loaded = false;

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
      LocalDatabase._db.addCollectionListener(_query!);
      final data = await LocalDatabase._db.loadCollection(_query!);
      if (isNotEmpty) {
        clear();
        notify = true;
      }
      if (data.isNotEmpty) {
        notify = true;
        final addData = <T>[];
        _rawEntries = CollectionQuery._sort(
          parameters,
          List.from(data!.entries),
        );
        for (final tmp in _rawEntries) {
          if (tmp.key.isEmpty || tmp.value is! DynamicMap) {
            continue;
          }
          final value = createDocument("${path.trimQuery()}/${tmp.key}");
          value.value = value.fromMap(value.filterOnLoad(Map.from(tmp.value)));
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
    } catch (e) {
      _completer?.completeError(e);
      _completer = null;
    } finally {
      _completer?.complete();
      _completer = null;
    }
    return this;
  }

  void _handledOnUpdate(_LocalStoreDocumentUpdate update) {
    switch (update.status) {
      case _LocalStoreDocumentUpdateStatus.deleted:
        _deleteOnUpdate(update);
        break;
      default:
        final found = firstWhereOrNull((element) =>
            element.path.trimQuery().trimString("/") == update.path);
        if (found != null) {
          if (_query?.filter != null) {
            if (_query!.filter!.call(update.value)) {
              _modifyOnUpdate(found, update);
            } else {
              _deleteOnUpdate(update);
            }
          } else {
            _modifyOnUpdate(found, update);
          }
        } else {
          if (_query?.filter != null) {
            if (_query!.filter!.call(update.value)) {
              _addOnUpdate(update);
            }
          } else {
            _addOnUpdate(update);
          }
        }
        break;
    }
  }

  void _deleteOnUpdate(_LocalStoreDocumentUpdate update) {
    bool notify = false;
    value.removeWhere((element) {
      final remove = element.path.trimQuery().trimString("/") == update.path;
      if (remove) {
        notify = true;
      }
      return remove;
    });
    _rawEntries.removeWhere((element) => element.key == update.id);
    if (notify) {
      notifyListeners();
    }
  }

  void _modifyOnUpdate(T found, _LocalStoreDocumentUpdate update) {
    final pos = CollectionQuery._seek(parameters, _rawEntries, update.value);
    final oldPos = value.indexOf(found);
    if (pos == null) {
      if (found != update.origin) {
        found.value = found.fromMap(found.filterOnLoad(update.value));
      }
      final entry = _rawEntries[oldPos];
      _rawEntries[oldPos] = MapEntry(entry.key, Map.from(update.value));
    } else {
      if (found != update.origin) {
        found.value = found.fromMap(found.filterOnLoad(update.value));
      }
      if (pos == oldPos) {
        final entry = _rawEntries[pos];
        _rawEntries[pos] = MapEntry(entry.key, Map.from(update.value));
      } else if (pos < oldPos) {
        value.insert(pos, value.removeAt(oldPos));
        final entry = _rawEntries.removeAt(oldPos);
        _rawEntries.insert(pos, MapEntry(entry.key, Map.from(update.value)));
        notifyListeners();
      } else {
        value.insert(pos - 1, value.removeAt(oldPos));
        final entry = _rawEntries.removeAt(oldPos);
        _rawEntries.insert(
            pos - 1, MapEntry(entry.key, Map.from(update.value)));
        notifyListeners();
      }
    }
  }

  void _addOnUpdate(_LocalStoreDocumentUpdate update) {
    final val = createDocument("${path.trimQuery()}/${update.id}");
    final pos = CollectionQuery._seek(parameters, _rawEntries, update.value);
    if (pos == null || (_rawEntries.length <= pos)) {
      val.value = val.fromMap(val.filterOnLoad(update.value));
      value.add(val);
      _rawEntries.add(MapEntry(update.id, Map.from(update.value)));
    } else {
      val.value = val.fromMap(val.filterOnLoad(update.value));
      value.insert(pos, val);
      _rawEntries.insert(pos, MapEntry(update.id, Map.from(update.value)));
    }
    notifyListeners();
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
  Future<LocalCollectionModel<T>> reload() async {
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
  Future<LocalCollectionModel<T>> loadOnce() async {
    if (!loaded) {
      loaded = true;
      return load();
    }
    return this;
  }
}
