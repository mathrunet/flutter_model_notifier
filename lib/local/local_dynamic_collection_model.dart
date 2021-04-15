part of model_notifier;

/// Base class for holding and manipulating data from a local database as a collection of [LocalDocumentModel].
///
/// The [load()] method retrieves the value from the local database and
/// the [save()] method saves the value to the local database.
///
/// The local database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [List],
/// it is possible to operate the content as it is.
final localCollectionProvider =
    ModelProvider.family<LocalDynamicCollectionModel, String>(
  (_, path) => LocalDynamicCollectionModel(path),
);

/// Specify the path and use [Map<String, dynamic>] to
/// hold the data [LocalCollectionModel].
///
/// You don't need to define a class to hold data strictly,
/// so you can develop quickly, but it lacks stability.
class LocalDynamicCollectionModel
    extends LocalCollectionModel<LocalDynamicDocumentModel>
    implements DynamicCollectionModel<LocalDynamicDocumentModel> {
  /// Specify the path and use [Map<String, dynamic>] to
  /// hold the data [LocalCollectionModel].
  ///
  /// You don't need to define a class to hold data strictly,
  /// so you can develop quickly, but it lacks stability.
  LocalDynamicCollectionModel(String path,
      [List<LocalDynamicDocumentModel>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(path, value ?? []);

  /// Add a process to create a document object.
  @override
  @protected
  LocalDynamicDocumentModel createDocument(String path) =>
      LocalDynamicDocumentModel(path);
}
