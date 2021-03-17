part of model_notifier;

/// A model that can be treated as a list.
///
/// The contents of the list are all classes of [Listenable].
abstract class ListModel<T extends Listenable> extends ValueModel<List<T>>
    with ListModelMixin<T>
    implements List<T> {
  /// A model that can be treated as a list.
  ///
  /// The contents of the list are all classes of [Listenable].
  ListModel([List<T>? listenables]) : super(listenables ?? []);
}
