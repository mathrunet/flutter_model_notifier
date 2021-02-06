part of model_notifier;

class LocalDynamicCollectionModel
    extends LocalCollectionModel<LocalDynamicDocumentModel> {
  LocalDynamicCollectionModel(String path,
      [List<LocalDynamicDocumentModel> value = const []])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(path, value);

  @override
  @protected
  LocalDynamicDocumentModel createDocument(String path) =>
      LocalDynamicDocumentModel(path);
}
