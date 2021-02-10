part of model_notifier;

abstract class Model<T> extends ChangeNotifier {
  Model() {
    initState();
  }

  @protected
  final StreamController<T> streamController = StreamController<T>();

  Stream<T> get stream => streamController.stream;

  @protected
  @mustCallSuper
  void initState() {}
}
