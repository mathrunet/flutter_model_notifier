part of model_notifier;

abstract class ListModel<T extends Listenable> extends ListNotifier<T>
    implements List<T>, StoredModel<List<T>> {
  ListModel([List<T> listenables = const []]) : super(listenables) {
    initState();
  }

  @protected
  @mustCallSuper
  void initState() {}
}
