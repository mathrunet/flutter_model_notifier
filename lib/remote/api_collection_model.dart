part of model_notifier;

abstract class ApiCollectionModel<T> extends ValueModel<List<T>>
    with ListModelMixin<T> {
  ApiCollectionModel(this.endpoint, [List<T> value = const []]) : super(value);

  final String endpoint;

  String get getEndpoint => endpoint;

  String get postEndpoint => endpoint;

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
  Future<List<T>> load() async {
    await onLoad();
    final res = await get(Uri.parse(getEndpoint), headers: getHeaders);
    onCatchResponse(res);
    final data = fromCollection(filterOnLoad(fromResponse(res.body)));
    addAll(data);
    await onDidLoad();
    return this;
  }

  @override
  Future<List<T>> save() async {
    await onSave();
    final res = await post(
      Uri.parse(postEndpoint),
      headers: postHeaders,
      body: toRequest(filterOnSave(toCollection(this))),
    );
    onCatchResponse(res);
    await onDidSave();
    return this;
  }
}
