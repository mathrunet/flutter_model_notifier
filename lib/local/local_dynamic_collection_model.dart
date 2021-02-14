part of model_notifier;

final localCollectionProvider =
    ModelProvider.family<LocalDynamicCollectionModel, String>(
  (_, path) => LocalDynamicCollectionModel(path)..load(),
);

class LocalDynamicCollectionModel
    extends LocalCollectionModel<LocalDynamicDocumentModel> {
  LocalDynamicCollectionModel(String path,
      [List<LocalDynamicDocumentModel>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(path, value ?? []);

  @override
  @protected
  LocalDynamicDocumentModel createDocument(String path) =>
      LocalDynamicDocumentModel(path);
}
