part of model_notifier;

/// Abstract class for the document model.
///
/// It defines the required methods.
abstract class DocumentModel<T> extends ValueModel<T> {
  /// Abstract class for the document model.
  ///
  /// It defines the required methods.
  DocumentModel(T value) : super(value);

  /// Creates a specific object from a given [map].
  ///
  /// This is used to convert the loaded data into an object for internal management.
  T fromMap(Map<String, dynamic> map);

  /// Creates a [Map<String, dynamic>] from its own [value].
  ///
  /// It is used for storing data.
  Map<String, dynamic> toMap(T value);
}
