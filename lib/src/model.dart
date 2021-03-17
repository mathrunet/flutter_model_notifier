part of model_notifier;

/// You can create a [Model] based on a [ChangeNotifier].
abstract class Model<T> extends ChangeNotifier {
  /// You can create a [Model] based on a [ChangeNotifier].
  Model() {
    initState();
  }

  /// The method to be executed when initialization is performed.
  @protected
  @mustCallSuper
  void initState() {}
}
