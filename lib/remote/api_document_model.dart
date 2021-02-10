part of model_notifier;

abstract class ApiDocumentModel<T> extends DocumentModel<T>
    implements StoredModel<T> {
  ApiDocumentModel(this.endpoint, T initialValue) : super(initialValue);

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    value = initialValue;
  }

  @protected
  T get initialValue;

  final String endpoint;

  String get getEndpoint => endpoint;

  String get postEndpoint => endpoint;

  Map<String, String> get getHeaders => {};

  Map<String, String> get postHeaders => {};

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
  Map<String, Object> fromResponse(String json) => jsonDecodeAsMap(json);

  @protected
  dynamic toRequest(Map<String, Object> map) => jsonEncode(map);

  @protected
  @mustCallSuper
  Map<String, Object> filterOnLoad(Map<String, Object> loaded) => loaded;

  @protected
  @mustCallSuper
  Map<String, Object> filterOnSave(Map<String, Object> save) => save;

  @override
  Future<T> load() async {
    await onLoad();
    final res = await get(Uri.parse(getEndpoint), headers: getHeaders);
    onCatchResponse(res);
    value = fromMap(filterOnLoad(fromResponse(res.body)));
    streamController.sink.add(value);
    notifyListeners();
    await onDidLoad();
    return value;
  }

  @override
  Future<T> save() async {
    await onSave();
    final res = await post(
      Uri.parse(postEndpoint),
      headers: postHeaders,
      body: toRequest(filterOnSave(toMap(value))),
    );
    onCatchResponse(res);
    streamController.sink.add(value);
    notifyListeners();
    await onDidSave();
    return value;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ endpoint.hashCode;
}
