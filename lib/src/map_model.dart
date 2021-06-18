part of model_notifier;

/// A model that can be treated as a map.
///
/// All keys in the map will be of type [String].
abstract class MapModel<T> extends ValueModel<Map<String, T>>
    with MapModelMixin<String, T>
    implements Map<String, T> {
  /// A model that can be treated as a map.
  ///
  /// All keys in the map will be of type [String].
  MapModel([Map<String, T>? map]) : super(map ?? {});
}
