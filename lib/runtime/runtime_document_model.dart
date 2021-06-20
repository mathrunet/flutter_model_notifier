part of model_notifier;

/// Base class for holding and manipulating data from a runtime database as a document of [T].
///
/// The runtime database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [Map],
/// it is possible to operate the content as it is.
abstract class RuntimeDocumentModel<T> extends DocumentModel<T>
    implements
        StoredModel<T, RuntimeDocumentModel<T>>,
        DocumentMockModel<T, RuntimeDocumentModel<T>> {
  /// Base class for holding and manipulating data from a runtime database as a document of [T].
  ///
  /// The runtime database is a Json database.
  /// Specify a path to specify the location of the contents.
  ///
  /// In addition, since it can be used as [Map],
  /// it is possible to operate the content as it is.
  RuntimeDocumentModel(this.path, T initialValue)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(initialValue);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old value as evaluated by the equality operator ==,
  /// this class notifies its listeners.
  @override
  set value(T newValue) {
    if (super.value == newValue) {
      return;
    }
    super.value = newValue;
  }

  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have changed. Listeners that are added during this iteration
  /// will not be visited. Listeners that are removed during this iteration will
  /// not be visited after they are removed.
  ///
  /// Exceptions thrown by listeners will be caught and reported using
  /// [FlutterError.reportError].
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (e.g.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removeListener].
  @override
  void notifyListeners() {
    _RuntimeDatabase._notifyChildChanges(this);
    super.notifyListeners();
  }

  /// Key for UID values.
  final String uidValueKey = Const.uid;

  /// Key for time values.
  final String timeValueKey = Const.time;

  /// Key for locale values.
  final String localeValueKey = MetaConst.locale;

  /// The method to be executed when initialization is performed.
  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isEnabledMockup && initialMock != null) {
      // ignore: null_check_on_nullable_type_parameter
      value = initialMock!;
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
    _RuntimeDatabase._removeDocument(this);
  }

  /// Initial value of mock.
  @override
  @protected
  final T? initialMock = null;

  /// Path of the local database.
  final String path;

  /// Returns itself after the load/save finishes.
  @override
  Future<void> get future => _completer?.future ?? Future.value();
  Completer<void>? _completer;

  /// Returns itself after the delete finishes.
  Future<void> get deleting => Future.value();

  /// Callback before the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  /// Callback before the save has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  /// Callback before the delete has been done.
  @protected
  @mustCallSuper
  Future<void> onDelete() async {}

  /// Callback after the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  /// Callback after the save has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onDidSave() async {}

  /// Callback after the delete has been done.
  @protected
  @mustCallSuper
  Future<void> onDidDelete() async {}

  /// You can filter the loaded content when it is loaded.
  ///
  /// Edit the value of [loaded] and return.
  @protected
  @mustCallSuper
  DynamicMap filterOnLoad(DynamicMap loaded) => loaded;

  /// You can filter the saving content when it is saving.
  ///
  /// Edit the value of [save] and return.
  @protected
  @mustCallSuper
  DynamicMap filterOnSave(DynamicMap save) => save;

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  RuntimeDocumentModel<T> mock(T mockData) {
    if (!Config.isEnabledMockup) {
      return this;
    }
    if (value == mockData) {
      return this;
    }
    value = mockData;
    notifyListeners();
    return this;
  }

  /// Retrieves data and updates the data in the model.
  ///
  /// You will be notified of model updates at the time they are retrieved.
  ///
  /// In addition,
  /// the updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<RuntimeDocumentModel<T>> load() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    try {
      await onLoad();
      _RuntimeDatabase._addDocument(this);
      value = fromMap(filterOnLoad(
          _RuntimeDatabase._root._readFromPath<DynamicMap>(path) ?? {}));
      notifyListeners();
      await onDidLoad();
      _completer?.complete();
      _completer = null;
    } finally {
      _completer?.completeError(e);
      _completer = null;
    }
    return this;
  }

  /// Data stored in the model is stored in a database external to the app that is tied to the model.
  ///
  /// The updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<RuntimeDocumentModel<T>> save() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    try {
      await onSave();
      _RuntimeDatabase._addDocument(this);
      final data = filterOnSave(toMap(value));
      _RuntimeDatabase._root._writeToPath(path, data);
      _RuntimeDatabase._syncDocument(this, data);
      _RuntimeDatabase._addChild(this);
      notifyListeners();
      await onDidSave();
      _completer?.complete();
      _completer = null;
    } finally {
      _completer?.completeError(e);
      _completer = null;
    }
    return this;
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<RuntimeDocumentModel<T>> reload() => load();

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<RuntimeDocumentModel<T>> loadOnce() async {
    if (isEmpty) {
      return load();
    }
    return this;
  }

  /// Deletes the document.
  ///
  /// Deleted documents are immediately reflected and removed from related collections, etc.
  Future<void> delete() async {
    if (_completer != null) {
      await future;
      return;
    }
    _completer = Completer<void>();
    try {
      await onDelete();
      _RuntimeDatabase._root._deleteFromPath(path);
      _RuntimeDatabase._deleteDocument(this);
      _RuntimeDatabase._removeChild(this);
      value = fromMap(filterOnLoad(const {}));
      await onDidDelete();
      _completer?.complete();
      _completer = null;
    } finally {
      _completer?.completeError(e);
      _completer = null;
    }
  }

  /// The equality operator.
  ///
  /// The default behavior for all [Object]s is to return true if and only if this object and [other] are the same object.
  ///
  /// Override this method to specify a different equality relation on a class. The overriding method must still be an equivalence relation. That is, it must be:
  ///
  /// Total: It must return a boolean for all arguments. It should never throw.
  ///
  /// Reflexive: For all objects o, o == o must be true.
  ///
  /// Symmetric: For all objects o1 and o2, o1 == o2 and o2 == o1 must either both be true, or both be false.
  ///
  /// Transitive: For all objects o1, o2, and o3, if o1 == o2 and o2 == o3 are true, then o1 == o3 must be true.
  ///
  /// The method should also be consistent over time, so whether two objects are equal should only change if at least one of the objects was modified.
  ///
  /// If a subclass overrides the equality operator, it should override the [hashCode] method as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// The hash code for this object.
  ///
  /// A hash code is a single integer which represents the state of the object that affects [operator ==] comparisons.
  ///
  /// All objects have hash codes. The default hash code implemented by [Object] represents only the identity of the object,
  /// the same way as the default [operator ==] implementation only considers objects equal if they are identical (see [identityHashCode]).
  ///
  /// If [operator ==] is overridden to use the object state instead,
  /// the hash code must also be changed to represent that state,
  /// otherwise the object cannot be used in hash based data structures like the default [Set] and [Map] implementations.
  ///
  /// Hash codes must be the same for objects that are equal to each other according to [operator ==].
  /// The hash code of an object should only change if the object changes in a way that affects equality.
  /// There are no further requirements for the hash codes. They need not be consistent between executions of the same program and there are no distribution guarantees.
  ///
  /// Objects that are not equal are allowed to have the same hash code.
  /// It is even technically allowed that all instances have the same hash code,
  /// but if clashes happen too often, it may reduce the efficiency of hash-based data structures like [HashSet] or [HashMap].
  ///
  /// If a subclass overrides [hashCode],
  /// it should override the [operator ==] operator as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ path.hashCode;
}
