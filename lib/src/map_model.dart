part of model_notifier;

abstract class MapModel<T> extends ValueModel<Map<String, T>>
    with MapModelMixin<T>
    implements Map<String, T> {
  MapModel([Map<String, T> map = const {}]) : super(map);
}
