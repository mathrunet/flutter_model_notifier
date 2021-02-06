part of model_notifier;

abstract class MapModel<T> extends MapNotifier<T>
    implements Map<String, T>, StoredModel<Map<String, T>> {
  MapModel([Map<String, T> map = const {}]) : super(map) {
    initState();
  }

  @protected
  @mustCallSuper
  void initState() {}
}
