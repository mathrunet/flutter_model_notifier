part of model_notifier;

abstract class LocalDocumentModel<T> extends DocumentModel<T>
    implements StoredModel<T, LocalDocumentModel<T>> {
  LocalDocumentModel(this.path, T initialValue)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(initialValue);

  @override
  set value(T newValue) {
    if (super.value == newValue) {
      return;
    }
    super.value = newValue;
    // _LocalDatabase._notifyChildChanges(this);
  }

  String get uidValueKey => "uid";
  String get timeValueKey => "time";

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _LocalDatabase._removeChild(this);
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    value ??= initialValue;
  }

  @protected
  T get initialValue;

  final String path;

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}
  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDelete() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDidDelete() async {}

  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnLoad(Map<String, dynamic> loaded) => loaded;

  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) => save;

  @override
  Future<LocalDocumentModel<T>> load() async {
    await _LocalDatabase.initialize();
    await onLoad();
    value = fromMap(filterOnLoad(
        _LocalDatabase._root._readFromPath<Map<String, dynamic>>(path) ??
            const {}));
    streamController.sink.add(value);
    notifyListeners();
    await onDidLoad();
    return this;
  }

  @override
  Future<LocalDocumentModel<T>> save() async {
    await _LocalDatabase.initialize();
    await onSave();
    _LocalDatabase._root._writeToPath(path, filterOnSave(toMap(value)));
    _LocalDatabase._addChild(this);
    _LocalDatabase._save();
    streamController.sink.add(value);
    notifyListeners();
    await onDidSave();
    return this;
  }

  Future<void> delete() async {
    await _LocalDatabase.initialize();
    await onDelete();
    _LocalDatabase._root._deleteFromPath(path);
    _LocalDatabase._removeChild(this);
    _LocalDatabase._save();
    streamController.sink.add(value);
    notifyListeners();
    await onDidDelete();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ path.hashCode;
}
