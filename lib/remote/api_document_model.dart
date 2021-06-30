part of model_notifier;

/// Class that can retrieve data from the RestAPI and store it as a document.
///
/// Basically, you get a  Map as a response of RestAPI and use it by converting it.
/// The data is converted using [fromResponse] and [toRequest].
///
/// Use `get` in the [load()] method and `post` in the [save()] method as HTTP methods.
abstract class ApiDocumentModel<T> extends DocumentModel<T>
    implements
        StoredModel<T, ApiDocumentModel<T>>,
        DocumentMockModel<T, ApiDocumentModel<T>> {
  /// Class that can retrieve data from the RestAPI and store it as a document.
  ///
  /// Basically, you get a  Map as a response of RestAPI and use it by converting it.
  /// The data is converted using [fromResponse] and [toRequest].
  ///
  /// Use `get` in the [load()] method and `post` in the [save()] method as HTTP methods.
  ApiDocumentModel(this.endpoint, T initialValue) : super(initialValue);

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

  /// Initial value of mock.
  @override
  @protected
  final T? initialMock = null;

  /// API endpoints.
  final String endpoint;

  /// The endpoint to use when executing the Get method.
  String get getEndpoint => endpoint;

  /// The endpoint to use when executing the Post method.
  String get postEndpoint => endpoint;

  /// The endpoint to use when executing the Put method.
  String get putEndpoint => endpoint;

  /// The endpoint to use when executing the Delete method.
  String get deleteEndpoint => endpoint;

  /// header when executing the Get method.
  Map<String, String> get getHeaders => {};

  /// header when executing the Post method.
  Map<String, String> get postHeaders => {};

  /// header when executing the Put method.
  Map<String, String> get putHeaders => {};

  /// header when executing the Delete method.
  Map<String, String> get deleteHeaders => {};

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

  /// Callback before the save has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onSave() async {}

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

  /// Callback to catch what to do with the response.
  ///
  /// Throwing Exceptions on responses, etc.
  @protected
  @mustCallSuper
  void onCatchResponse(Response response) {}

  /// Callback for converting to a map of objects for a response.
  @protected
  DynamicMap fromResponse(String json) => jsonDecodeAsMap(json);

  /// Callback for converting internal map data to request data.
  @protected
  dynamic toRequest(DynamicMap map) => jsonEncode(map);

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

  /// The actual loading process is done from the API when it is loaded.
  ///
  /// By overriding, it is possible to use plugins, etc.
  /// in addition to simply retrieving from the URL.
  @protected
  Future<void> loadRequest() async {
    final res = await get(Uri.parse(getEndpoint), headers: getHeaders);
    onCatchResponse(res);
    value = fromMap(filterOnLoad(fromResponse(res.body)));
  }

  /// The actual loading process is done from the API when it is saved.
  ///
  /// By overriding, it is possible to use plugins, etc.
  /// in addition to simply saving to the URL.
  @protected
  Future<void> saveRequest() async {
    final res = await post(
      Uri.parse(postEndpoint),
      headers: postHeaders,
      body: toRequest(filterOnSave(toMap(value))),
    );
    onCatchResponse(res);
  }

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  ApiDocumentModel<T> mock(T mockData) {
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
  Future<ApiDocumentModel<T>> load() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    try {
      await onLoad();
      await loadRequest();
      notifyListeners();
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

  /// Data stored in the model is stored in a database external to the app that is tied to the model.
  ///
  /// The updated [Resuult] can be obtained at the stage where the loading is finished.
  @override
  Future<ApiDocumentModel<T>> save() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    try {
      await onSave();
      await saveRequest();
      notifyListeners();
      await onDidSave();
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

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<ApiDocumentModel<T>> reload() => load();

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<ApiDocumentModel<T>> loadOnce() async {
    if (!loaded) {
      loaded = true;
      return load();
    }
    return this;
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
  int get hashCode => super.hashCode ^ endpoint.hashCode;
}
