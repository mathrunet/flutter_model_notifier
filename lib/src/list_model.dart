part of model_notifier;

abstract class ListModel<T extends Listenable> extends ValueModel<List<T>>
    with ListModelMixin<T>
    implements List<T> {
  ListModel([List<T>? listenables]) : super(listenables ?? []);
}
