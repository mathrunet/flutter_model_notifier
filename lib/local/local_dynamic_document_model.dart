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
final localDocumentProvider =
    ModelProvider.family<LocalDynamicDocumentModel, String>(
  (_, path) => LocalDynamicDocumentModel(path),
);

/// Specify the path and use [Map<String, dynamic>] to
/// hold the data [LocalDocumentModel].
///
/// You don't need to define a class to hold data strictly,
/// so you can develop quickly, but it lacks stability.
class LocalDynamicDocumentModel extends LocalDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic>, LocalDocumentMetaMixin<Map<String, dynamic>>
    implements DynamicDocumentModel {
  /// Specify the path and use [Map<String, dynamic>] to
  /// hold the data [LocalDocumentModel].
  ///
  /// You don't need to define a class to hold data strictly,
  /// so you can develop quickly, but it lacks stability.
  LocalDynamicDocumentModel(String path, [Map<String, dynamic>? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  /// If this value is `true`,
  /// Notify changes when there are changes in the map itself using map-specific methods.
  @override
  @protected
  bool get notifyOnChangeMap => false;

  // @override
  // void notifyListeners() {
  //   super.notifyListeners();
  //   _LocalDatabase._notifyChildChanges(this);
  // }

  /// Creates a specific object from a given [map].
  ///
  /// This is used to convert the loaded data into an object for internal management.
  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) =>
      map.cast<String, dynamic>();

  /// Creates a specific object from a given [map].
  ///
  /// This is used to convert the loaded data into an object for internal management.
  @override
  Map<String, dynamic> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();
}
