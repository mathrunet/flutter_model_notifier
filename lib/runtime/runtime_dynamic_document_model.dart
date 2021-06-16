part of model_notifier;

/// Base class for holding and manipulating data from a local database as a document of [T].
///
/// The [load()] method retrieves the value from the local database and
/// the [save()] method saves the value to the local database.
///
/// The local database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [Map],
/// it is possible to operate the content as it is.
final runtimeDocumentProvider =
    ModelProvider.family<RuntimeDynamicDocumentModel, String>(
  (_, path) => RuntimeDynamicDocumentModel(path),
);

/// Specify the path and use [DynamicMap] to
/// hold the data [LocalDocumentModel].
///
/// You don't need to define a class to hold data strictly,
/// so you can develop quickly, but it lacks stability.
class RuntimeDynamicDocumentModel extends RuntimeDocumentModel<DynamicMap>
    with MapModelMixin<dynamic>, RuntimeDocumentMetaMixin<DynamicMap>
    implements DynamicDocumentModel {
  /// Specify the path and use [DynamicMap] to
  /// hold the data [LocalDocumentModel].
  ///
  /// You don't need to define a class to hold data strictly,
  /// so you can develop quickly, but it lacks stability.
  RuntimeDynamicDocumentModel(String path, [DynamicMap? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  /// If this value is `true`,
  /// Notify changes when there are changes in the map itself using map-specific methods.
  @override
  @protected
  bool get notifyOnChangeMap => true;

  // @override
  // void notifyListeners() {
  //   super.notifyListeners();
  //   _LocalDatabase._notifyChildChanges(this);
  // }

  /// Creates a specific object from a given [map].
  ///
  /// This is used to convert the loaded data into an object for internal management.
  @override
  DynamicMap fromMap(DynamicMap map) => map.cast<String, dynamic>();

  /// Creates a specific object from a given [map].
  ///
  /// This is used to convert the loaded data into an object for internal management.
  @override
  DynamicMap toMap(DynamicMap value) => value.cast<String, dynamic>();

  /// Deletes the document.
  ///
  /// Deleted documents are immediately reflected and removed from related collections, etc.
  @override
  Future<void> delete() async {
    await onDelete();
    _RuntimeDatabase._removeChild(this);
    clear();
    notifyListeners();
    await onDidDelete();
  }
}
