part of model_notifier;

final localDocumentProvider =
    ModelProvider.family.autoDispose<LocalDynamicDocumentModel, String>(
  (_, path) => LocalDynamicDocumentModel(path)..load(),
);

class LocalDynamicDocumentModel extends LocalDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic> {
  LocalDynamicDocumentModel(String path, [Map<String, dynamic>? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  @override
  void notifyListeners() {
    super.notifyListeners();
    _LocalDatabase._notifyChildChanges(this);
  }

  @override
  Map<String, dynamic> fromMap(Map<String, Object> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, Object> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();

  @override
  @protected
  Map<String, dynamic> get initialValue => {};
}
