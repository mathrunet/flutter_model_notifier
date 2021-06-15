part of model_notifier;

/// Class that can retrieve data from the RestAPI and store it as a collection of value.
///
/// Basically, you get a List of Map or a Map of Map as a response of RestAPI and use it by converting it.
/// The data is converted using [fromResponse] and [toRequest].
///
/// Use `get` in the [load()] method and `post` in the [save()] method as HTTP methods.
abstract class ApiCollectionModel<T> extends ValueModel<List<T>>
    with ListModelMixin<T>
    implements
        List<T>,
        StoredModel<List<T>, ApiCollectionModel<T>>,
        CollectionMockModel<T, ApiCollectionModel<T>> {
  /// Class that can retrieve data from the RestAPI and store it as a collection of value.
  ///
  /// Basically, you get a List of Map or a Map of Map as a response of RestAPI and use it by converting it.
  /// The data is converted using [fromCollection] and [toCollection].
  ///
  /// Use `get` in the [load()] method and `post` in the [save()] method as HTTP methods.
  ApiCollectionModel(this.endpoint, [List<T>? value]) : super(value ?? []);

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

  /// Returns itself after the load finishes.
  @override
  Future<ApiCollectionModel<T>> get loading =>
      _loadingCompleter?.future ?? Future.value(this);
  Completer<ApiCollectionModel<T>>? _loadingCompleter;

  /// Returns itself after the save finishes.
  @override
  Future<ApiCollectionModel<T>> get saving =>
      _savingCompleter?.future ?? Future.value(this);
  Completer<ApiCollectionModel<T>>? _savingCompleter;

  /// If this value is `true`,
  /// Notify changes when there are changes in the list itself using list-specific methods.
  @override
  bool get notifyOnChangeList => false;

  /// If this value is `true`,
  /// the change will be notified when [value] itself is changed.
  @override
  bool get notifyOnChangeValue => true;

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

  /// Callback for converting the data retrieved from the API as collection data.
  List<T> fromCollection(List<Object> list);

  /// Callback for converting internal collection data when POSTing to the API.
  List<Object> toCollection(List<T> list);

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

  /// Callback for converting to a list of objects for a response.
  @protected
  List<Object> fromResponse(String json) => jsonDecodeAsList(json);

  /// Callback for converting internal list data to request data.
  @protected
  dynamic toRequest(List<Object> list) => jsonEncode(list);

  /// You can filter the loaded content when it is loaded.
  ///
  /// Edit the value of [loaded] and return.
  @protected
  @mustCallSuper
  List<Object> filterOnLoad(List<Object> loaded) => loaded;

  /// You can filter the saving content when it is saving.
  ///
  /// Edit the value of [save] and return.
  @protected
  @mustCallSuper
  List<Object> filterOnSave(List<Object> save) => save;

  /// Add a process to create a document object.
  @protected
  T createDocument();

  /// Create a new document.
  T create() => createDocument();

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  ApiCollectionModel<T> mock(List<T> mockDataList) {
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
  Future<ApiCollectionModel<T>> load() async {
    if (_loadingCompleter != null) {
      return loading;
    }
    _loadingCompleter = Completer<ApiCollectionModel<T>>();
    try {
      await onLoad();
      final res = await get(Uri.parse(getEndpoint), headers: getHeaders);
      onCatchResponse(res);
      final data = fromCollection(filterOnLoad(fromResponse(res.body)));
      addAll(data);
      notifyListeners();
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
  Future<ApiCollectionModel<T>> save() async {
    if (_savingCompleter != null) {
      return saving;
    }
    _savingCompleter = Completer<ApiCollectionModel<T>>();
    try {
      await onSave();
      final res = await post(
        Uri.parse(postEndpoint),
        headers: postHeaders,
        body: toRequest(filterOnSave(toCollection(this))),
      );
      onCatchResponse(res);
      notifyListeners();
      await onDidSave();
      _savingCompleter?.complete(this);
      _savingCompleter = null;
    } catch (e) {
      _savingCompleter?.completeError(e);
      _savingCompleter = null;
      rethrow;
    }
    return this;
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<ApiCollectionModel<T>> reload() async {
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
  Future<ApiCollectionModel<T>> loadOnce() async {
    if (isEmpty) {
      return load();
    }
    return this;
  }
}
