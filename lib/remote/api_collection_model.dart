part of model_notifier;

abstract class ApiCollectionModel<T> extends ValueModel<List<T>>
    with ListModelMixin<T>
    implements
        StoredModel<List<T>, ApiCollectionModel<T>>,
        CollectionMockModel<T, ApiCollectionModel<T>> {
  ApiCollectionModel(this.endpoint, [List<T>? value]) : super(value ?? []);

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isMockup) {
      value = fromCollection(filterOnLoad(initialMock));
    }
  }

  @override
  @protected
  final List<Map<String, dynamic>> initialMock = const [];

  @override
  bool get notifyOnChangeList => false;

  @override
  bool get notifyOnChangeValue => true;

  final String endpoint;

  String get getEndpoint => endpoint;

  String get postEndpoint => endpoint;

  String get putEndpoint => endpoint;

  String get deleteEndpoint => endpoint;

  Map<String, String> get getHeaders => {};

  Map<String, String> get postHeaders => {};

  List<T> fromCollection(List<Object> list);
  List<Object> toCollection(List<T> list);

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidSave() async {}

  @protected
  @mustCallSuper
  void onCatchResponse(Response response) {}

  @protected
  List<Object> fromResponse(String json) => jsonDecodeAsList(json);

  @protected
  dynamic toRequest(List<Object> list) => jsonEncode(list);

  @protected
  @mustCallSuper
  List<Object> filterOnLoad(List<Object> loaded) => loaded;

  @protected
  @mustCallSuper
  List<Object> filterOnSave(List<Object> save) => save;

  @protected
  T createDocument();

  T create() => createDocument();

  @override
  ApiCollectionModel<T> mock(List<Map<String, dynamic>> mockData) {
    if (!Config.isMockup) {
      return this;
    }
    final data =
        fromCollection(filterOnLoad(fromResponse(jsonEncode(mockData))));
    addAll(data);
    notifyListeners();
    return this;
  }

  @override
  Future<ApiCollectionModel<T>> load() async {
    await onLoad();
    final res = await get(Uri.parse(getEndpoint), headers: getHeaders);
    onCatchResponse(res);
    final data = fromCollection(filterOnLoad(fromResponse(res.body)));
    addAll(data);
    notifyListeners();
    await onDidLoad();
    return this;
  }

  @override
  Future<ApiCollectionModel<T>> save() async {
    await onSave();
    final res = await post(
      Uri.parse(postEndpoint),
      headers: postHeaders,
      body: toRequest(filterOnSave(toCollection(this))),
    );
    onCatchResponse(res);
    notifyListeners();
    await onDidSave();
    return this;
  }
}
